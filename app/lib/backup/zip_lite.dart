import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// A deliberately small ZIP writer and reader for the export format (ADR-003).
///
/// The reader treats the file as hostile input:
///  * only the files it is asked for BY EXACT NAME are ever opened; every other
///    path is ignored, so a name such as `../x` can never reach the disk;
///  * the number of files, the size of names, and the size of what is unpacked
///    are limited BEFORE and WHILE unpacking (a header that lies about its size
///    cannot make the app allocate more than the limit);
///  * anything unusual (encryption, ZIP64, split archives, unknown methods) is refused.
class ZipLimits {
  const ZipLimits({
    this.maxFileBytes = 64 * 1024 * 1024,
    this.maxFiles = 65534, // the classic ZIP index holds at most 65,535 names
    this.maxUnpackedBytes = 256 * 1024 * 1024,
  });

  /// Largest file that is read at all.
  final int maxFileBytes;

  /// Largest number of entries in the archive index.
  final int maxFiles;

  /// Largest total size of the files that are actually unpacked.
  final int maxUnpackedBytes;
}

class ZipException implements Exception {
  ZipException(this.message);
  final String message;
  @override
  String toString() => 'ZipException: $message';
}

class ZipEntry {
  ZipEntry(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

final _crcTable = () {
  final table = Uint32List(256);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
    }
    table[n] = c;
  }
  return table;
}();

int crc32(List<int> data) {
  var c = 0xFFFFFFFF;
  for (final b in data) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

Uint8List writeZip(List<ZipEntry> entries) {
  final out = BytesBuilder(copy: false);
  final central = BytesBuilder(copy: false);
  var offset = 0;
  const dosTime = 0;
  const dosDate = (0 << 9) | (1 << 5) | 1; // 1980-01-01: exports carry no file times
  for (final e in entries) {
    final name = utf8.encode(e.name);
    final crc = crc32(e.bytes);
    final deflated = Uint8List.fromList(ZLibCodec(raw: true, level: 6).encode(e.bytes));
    final useDeflate = deflated.length < e.bytes.length;
    final data = useDeflate ? deflated : e.bytes;
    final method = useDeflate ? 8 : 0;

    final local = ByteData(30);
    local.setUint32(0, 0x04034b50, Endian.little);
    local.setUint16(4, 20, Endian.little);
    local.setUint16(6, 0x0800, Endian.little); // UTF-8 names
    local.setUint16(8, method, Endian.little);
    local.setUint16(10, dosTime, Endian.little);
    local.setUint16(12, dosDate, Endian.little);
    local.setUint32(14, crc, Endian.little);
    local.setUint32(18, data.length, Endian.little);
    local.setUint32(22, e.bytes.length, Endian.little);
    local.setUint16(26, name.length, Endian.little);
    local.setUint16(28, 0, Endian.little);
    out
      ..add(local.buffer.asUint8List())
      ..add(name)
      ..add(data);

    final cd = ByteData(46);
    cd.setUint32(0, 0x02014b50, Endian.little);
    cd.setUint16(4, 20, Endian.little);
    cd.setUint16(6, 20, Endian.little);
    cd.setUint16(8, 0x0800, Endian.little);
    cd.setUint16(10, method, Endian.little);
    cd.setUint16(12, dosTime, Endian.little);
    cd.setUint16(14, dosDate, Endian.little);
    cd.setUint32(16, crc, Endian.little);
    cd.setUint32(20, data.length, Endian.little);
    cd.setUint32(24, e.bytes.length, Endian.little);
    cd.setUint16(28, name.length, Endian.little);
    cd.setUint32(42, offset, Endian.little);
    central
      ..add(cd.buffer.asUint8List())
      ..add(name);
    offset += 30 + name.length + data.length;
  }
  final centralBytes = central.toBytes();
  final end = ByteData(22);
  end.setUint32(0, 0x06054b50, Endian.little);
  end.setUint16(8, entries.length, Endian.little);
  end.setUint16(10, entries.length, Endian.little);
  end.setUint32(12, centralBytes.length, Endian.little);
  end.setUint32(16, offset, Endian.little);
  out
    ..add(centralBytes)
    ..add(end.buffer.asUint8List());
  return out.toBytes();
}

class _Index {
  _Index(this.name, this.method, this.crc, this.compressed, this.uncompressed, this.localOffset);
  final String name;
  final int method;
  final int crc;
  final int compressed;
  final int uncompressed;
  final int localOffset;
}

/// Reads the named files from [zip]. A wanted name that is missing is absent
/// from the result. Throws [ZipException] for anything malformed or over a limit.
Map<String, Uint8List> readZipFiles(Uint8List zip, Set<String> wanted, {ZipLimits limits = const ZipLimits()}) {
  if (zip.length > limits.maxFileBytes) throw ZipException('file too large');
  if (zip.length < 22) throw ZipException('too short');
  final view = ByteData.sublistView(zip);

  // End-of-central-directory record: last 22 bytes, or up to 64 KiB of comment before it.
  var eocd = -1;
  final lowest = zip.length - 22 - 0xFFFF < 0 ? 0 : zip.length - 22 - 0xFFFF;
  for (var i = zip.length - 22; i >= lowest; i--) {
    if (view.getUint32(i, Endian.little) == 0x06054b50) {
      eocd = i;
      break;
    }
  }
  if (eocd < 0) throw ZipException('not a ZIP file');
  final disk = view.getUint16(eocd + 4, Endian.little);
  final cdDisk = view.getUint16(eocd + 6, Endian.little);
  final countHere = view.getUint16(eocd + 8, Endian.little);
  final count = view.getUint16(eocd + 10, Endian.little);
  final cdSize = view.getUint32(eocd + 12, Endian.little);
  final cdOffset = view.getUint32(eocd + 16, Endian.little);
  if (disk != 0 || cdDisk != 0 || countHere != count) throw ZipException('split archive');
  if (count == 0xFFFF || cdSize == 0xFFFFFFFF || cdOffset == 0xFFFFFFFF) throw ZipException('ZIP64 is not supported');
  if (count > limits.maxFiles) throw ZipException('too many files');
  if (cdOffset + cdSize > eocd) throw ZipException('bad directory');

  final index = <String, _Index>{};
  var p = cdOffset;
  for (var i = 0; i < count; i++) {
    if (p + 46 > eocd) throw ZipException('bad directory');
    if (view.getUint32(p, Endian.little) != 0x02014b50) throw ZipException('bad directory');
    final flags = view.getUint16(p + 8, Endian.little);
    final method = view.getUint16(p + 10, Endian.little);
    final crc = view.getUint32(p + 16, Endian.little);
    final comp = view.getUint32(p + 20, Endian.little);
    final uncomp = view.getUint32(p + 24, Endian.little);
    final nameLen = view.getUint16(p + 28, Endian.little);
    final extraLen = view.getUint16(p + 30, Endian.little);
    final commentLen = view.getUint16(p + 32, Endian.little);
    final local = view.getUint32(p + 42, Endian.little);
    if (nameLen > 1024) throw ZipException('name too long');
    if (p + 46 + nameLen + extraLen + commentLen > eocd) throw ZipException('bad directory');
    final nameBytes = zip.sublist(p + 46, p + 46 + nameLen);
    p += 46 + nameLen + extraLen + commentLen;

    String name;
    try {
      name = utf8.decode(nameBytes);
    } catch (_) {
      continue; // a name we cannot read is never one we asked for
    }
    if (!wanted.contains(name)) continue; // ignored: never opened, never written anywhere
    if ((flags & 0x1) != 0) throw ZipException('encrypted entries are not supported');
    if (method != 0 && method != 8) throw ZipException('unknown method');
    if (comp == 0xFFFFFFFF || uncomp == 0xFFFFFFFF) throw ZipException('ZIP64 is not supported');
    if (index.containsKey(name)) throw ZipException('duplicate name');
    index[name] = _Index(name, method, crc, comp, uncomp, local);
  }

  var budget = limits.maxUnpackedBytes;
  final result = <String, Uint8List>{};
  for (final e in index.values) {
    if (e.uncompressed > budget) throw ZipException('unpacked size over the limit');
    if (e.localOffset + 30 > cdOffset) throw ZipException('bad entry');
    if (view.getUint32(e.localOffset, Endian.little) != 0x04034b50) throw ZipException('bad entry');
    final nameLen = view.getUint16(e.localOffset + 26, Endian.little);
    final extraLen = view.getUint16(e.localOffset + 28, Endian.little);
    final start = e.localOffset + 30 + nameLen + extraLen;
    final end = start + e.compressed;
    if (end > cdOffset || end < start) throw ZipException('bad entry');
    final raw = Uint8List.sublistView(zip, start, end);
    final Uint8List data;
    if (e.method == 0) {
      if (raw.length != e.uncompressed) throw ZipException('size mismatch');
      data = raw;
    } else {
      data = _inflateCapped(raw, e.uncompressed);
    }
    if (data.length != e.uncompressed) throw ZipException('size mismatch');
    if (crc32(data) != e.crc) throw ZipException('checksum mismatch');
    budget -= data.length;
    result[e.name] = data;
  }
  return result;
}

/// Inflates [raw], and stops with an error as soon as more than [cap] bytes come out,
/// whatever the header claimed.
Uint8List _inflateCapped(Uint8List raw, int cap) {
  final out = BytesBuilder(copy: false);
  var total = 0;
  final conv = ZLibDecoder(raw: true).startChunkedConversion(
    _CapSink((chunk) {
      total += chunk.length;
      if (total > cap) throw ZipException('unpacked size over the limit');
      out.add(chunk);
    }),
  );
  try {
    conv.add(raw);
    conv.close();
  } on ZipException {
    rethrow;
  } catch (_) {
    throw ZipException('damaged data');
  }
  return out.toBytes();
}

class _CapSink extends ByteConversionSinkBase {
  _CapSink(this._onChunk);
  final void Function(List<int>) _onChunk;

  @override
  void add(List<int> chunk) => _onChunk(chunk);

  @override
  void close() {}
}
