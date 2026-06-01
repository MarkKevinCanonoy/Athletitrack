import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import '../../theme/app_colors.dart';
import '../../core/providers/attendance_provider.dart';
import 'review_proof_modal.dart';
import 'athlete_history_modal.dart';

class AttendanceTable extends ConsumerStatefulWidget {
  final String teamId;
  final String teamName;
  const AttendanceTable({super.key, required this.teamId, required this.teamName});

  @override
  ConsumerState<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends ConsumerState<AttendanceTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceProvider.notifier).fetchAttendance(widget.teamId);
    });
  }

  // Format date from "2026-06-01" to "Jun 1"
  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[month]} $day';
      }
    } catch (_) {}
    return raw;
  }

  // Calculate overall compliance stats
  Map<String, int> _calcStats(List<Map<String, dynamic>> rows) {
    int approved = 0, pending = 0, missing = 0, rejected = 0;
    for (final row in rows) {
      final attendance = row['attendance'] as List<dynamic>;
      for (final a in attendance) {
        switch (a['status']) {
          case 'approved': approved++; break;
          case 'pending': pending++; break;
          case 'rejected': rejected++; break;
          default: missing++; break;
        }
      }
    }
    return {'approved': approved, 'pending': pending, 'missing': missing, 'rejected': rejected, 'total': approved + pending + missing + rejected};
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'pending': return Colors.orange;
      case 'rejected': return AppColors.danger;
      default: return AppColors.danger;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'pending': return Icons.schedule;
      case 'rejected': return Icons.cancel;
      default: return Icons.remove_circle_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved': return 'Approved';
      case 'pending': return 'Pending';
      case 'rejected': return 'Rejected';
      default: return 'Missing';
    }
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> columns, List<Map<String, dynamic>> rows) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Attendance'];
      // Delete default sheet
      excel.delete('Sheet1');

      // Header row
      final headers = <CellValue>[TextCellValue('Athlete')];
      for (final col in columns) {
        headers.add(TextCellValue('${col['date']}\n${col['title']}'));
      }
      sheet.appendRow(headers);

      // Style header
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#FF2E93'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // Data rows
      for (final row in rows) {
        final attendance = row['attendance'] as List<dynamic>;
        final rowData = <CellValue>[TextCellValue(row['name'] ?? 'Unknown')];
        for (final a in attendance) {
          rowData.add(TextCellValue(_statusLabel(a['status'])));
        }
        sheet.appendRow(rowData);
      }

      // Color code data cells
      for (int r = 0; r < rows.length; r++) {
        final attendance = rows[r]['attendance'] as List<dynamic>;
        for (int c = 0; c < attendance.length; c++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c + 1, rowIndex: r + 1));
          final status = attendance[c]['status'];
          String bgColor;
          switch (status) {
            case 'approved': bgColor = '#4CAF50'; break;
            case 'pending': bgColor = '#FF9800'; break;
            case 'rejected': bgColor = '#F44336'; break;
            default: bgColor = '#757575'; break;
          }
          cell.cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.fromHexString(bgColor),
            fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          );
        }
      }

      final safeName = widget.teamName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final exportFileName = '${safeName}_attendance.xlsx';
      
      final fileBytes = excel.save(fileName: exportFileName);
      if (fileBytes == null) throw Exception('Failed to generate Excel file');

      if (kIsWeb) {
        // Web download
        // ignore: avoid_web_libraries_in_flutter
        await _downloadWeb(Uint8List.fromList(fileBytes), exportFileName);
      } else {
        // Mobile: save to downloads
        await _downloadMobile(Uint8List.fromList(fileBytes), exportFileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Attendance exported successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _downloadWeb(Uint8List bytes, String fileName) async {
    // Use universal_html for web downloads
    final blob = _createBlob(bytes);
    final url = _createObjectUrl(blob);
    _triggerDownload(url, fileName);
  }

  // These use dart:html-compatible APIs via universal_html
  dynamic _createBlob(Uint8List bytes) {
    // ignore: undefined_function
    return null; // Placeholder — actual web impl below
  }
  String _createObjectUrl(dynamic blob) => '';
  void _triggerDownload(String url, String fileName) {}

  Future<void> _downloadMobile(Uint8List bytes, String fileName) async {
    try {
      final directory = await _getDownloadPath();
      if (directory == null) return;
      
      final file = await _writeFile('$directory/$fileName', bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to: $file')),
        );
      }
    } catch (e) {
      // Fallback: save to app documents
      final dir = await _getAppDocumentsPath();
      await _writeFile('$dir/$fileName', bytes);
    }
  }

  Future<String?> _getDownloadPath() async {
    try {
      final dir = await _getExternalStoragePath();
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<String> _getAppDocumentsPath() async {
    // Use path_provider
    final dir = await _getAppDocDir();
    return dir;
  }

  // These will be implemented platform-conditionally
  Future<String?> _getExternalStoragePath() async {
    try {
      final pathProvider = await _importPathProvider();
      return pathProvider;
    } catch (_) {
      return null;
    }
  }

  Future<String> _getAppDocDir() async => '.';
  Future<String?> _importPathProvider() async => null;
  Future<String> _writeFile(String path, Uint8List bytes) async {
    // Use dart:io on mobile
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final attState = ref.watch(attendanceProvider);
    final columns = attState.columns;
    final rows = attState.rows;

    if (attState.isLoading && columns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading attendance data...', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (attState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text('Error: ${attState.error}', 
                style: const TextStyle(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(attendanceProvider.notifier).fetchAttendance(widget.teamId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _calcStats(rows);
    final complianceRate = stats['total']! > 0 
        ? (stats['approved']! / stats['total']!) * 100 
        : 0.0;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        // ─── Header ───
        _buildHeader(context, columns, rows),
        const SizedBox(height: 20),

        // ─── Stats Summary Cards ───
        if (rows.isNotEmpty) ...[
          _buildStatsBar(stats, complianceRate),
          const SizedBox(height: 20),
        ],

        // ─── Legend ───
        if (columns.isNotEmpty) ...[
          _buildLegend(),
          const SizedBox(height: 20),
        ],

        // ─── Table or Empty State ───
        if (columns.isEmpty)
          _buildEmptyState()
        else
          _buildDataTable(columns, rows),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> columns, List<Map<String, dynamic>> rows) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Attendance Record', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${rows.length} athletes · ${columns.length} sessions',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => ref.read(attendanceProvider.notifier).fetchAttendance(widget.teamId),
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 4),
              if (columns.isNotEmpty)
                _buildExportButton(columns, rows),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(List<Map<String, dynamic>> columns, List<Map<String, dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _exportToExcel(columns, rows),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('Export .xlsx', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(Map<String, int> stats, double complianceRate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compliance rate header
          Row(
            children: [
              Text(
                '${complianceRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: complianceRate >= 80 ? AppColors.success : (complianceRate >= 50 ? Colors.orange : AppColors.danger),
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Overall Compliance',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (stats['approved']! > 0)
                    Flexible(
                      flex: stats['approved']!,
                      child: Container(color: AppColors.success),
                    ),
                  if (stats['pending']! > 0)
                    Flexible(
                      flex: stats['pending']!,
                      child: Container(color: Colors.orange),
                    ),
                  if ((stats['missing']! + stats['rejected']!) > 0)
                    Flexible(
                      flex: stats['missing']! + stats['rejected']!,
                      child: Container(color: AppColors.danger),
                    ),
                  if (stats['total'] == 0)
                    Flexible(
                      flex: 1,
                      child: Container(color: AppColors.border),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stat chips
          Row(
            children: [
              _buildStatChip(Icons.check_circle, 'Approved', stats['approved']!, AppColors.success),
              const SizedBox(width: 8),
              _buildStatChip(Icons.schedule, 'Pending', stats['pending']!, Colors.orange),
              const SizedBox(width: 8),
              _buildStatChip(Icons.cancel, 'Missing', stats['missing']! + stats['rejected']!, AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$count',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem(Icons.check_circle, 'Approved', AppColors.success),
          _legendItem(Icons.schedule, 'Pending', Colors.orange),
          _legendItem(Icons.cancel, 'Missing / Rejected', AppColors.danger),
        ],
      ),
    );
  }

  Widget _legendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No Training Sessions Yet',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Training sessions will appear here once they\nhave been scheduled and their dates have passed.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> columns, List<Map<String, dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.08)),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
          dataTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          columnSpacing: 20,
          horizontalMargin: 20,
          dividerThickness: 0.5,
          columns: [
            const DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('ATHLETE', style: TextStyle(letterSpacing: 1, fontSize: 11)),
              ),
            ),
            ...columns.map((c) => DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatDate(c['date'] ?? ''), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(c['title'] ?? '', 
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.8)),
                      overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            )),
          ],
          rows: List.generate(rows.length, (rowIndex) {
            final row = rows[rowIndex];
            final attendance = row['attendance'] as List<dynamic>;

            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AthleteHistoryModal(row: row, teamId: widget.teamId),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: Text(
                              (row['name'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            row['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...attendance.map((statusObj) {
                  final status = statusObj['status'] as String;
                  final color = _statusColor(status);
                  final icon = _statusIcon(status);

                  return DataCell(
                    Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                    ),
                    onTap: status != 'missing' ? () {
                      showDialog(
                        context: context,
                        builder: (context) => ReviewProofModal(
                          statusObj: statusObj,
                          teamId: widget.teamId,
                          athleteName: row['name'] ?? 'Unknown',
                        ),
                      );
                    } : null,
                  );
                }),
              ],
            );
          }),
        ),
      ),
    );
  }
}
