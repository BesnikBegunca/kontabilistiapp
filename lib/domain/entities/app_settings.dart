import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final int? id;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String currency;
  final double defaultVatRate;
  final String? backupFolderPath;
  final String themeMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppSettings({
    this.id,
    required this.invoicePrefix,
    required this.nextInvoiceNumber,
    required this.currency,
    required this.defaultVatRate,
    this.backupFolderPath,
    required this.themeMode,
    required this.createdAt,
    required this.updatedAt,
  });

  AppSettings copyWith({
    int? id,
    String? invoicePrefix,
    int? nextInvoiceNumber,
    String? currency,
    double? defaultVatRate,
    String? backupFolderPath,
    String? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      currency: currency ?? this.currency,
      defaultVatRate: defaultVatRate ?? this.defaultVatRate,
      backupFolderPath: backupFolderPath ?? this.backupFolderPath,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, invoicePrefix, nextInvoiceNumber, currency, defaultVatRate, backupFolderPath, themeMode, createdAt, updatedAt];
}
