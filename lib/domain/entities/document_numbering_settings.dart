import 'package:equatable/equatable.dart';

class DocumentNumberingSettings extends Equatable {
  final String outgoingInvoicePrefix;
  final int nextOutgoingInvoiceNumber;
  final String incomingInvoicePrefix;
  final int nextIncomingInvoiceNumber;

  const DocumentNumberingSettings({
    required this.outgoingInvoicePrefix,
    required this.nextOutgoingInvoiceNumber,
    required this.incomingInvoicePrefix,
    required this.nextIncomingInvoiceNumber,
  });

  @override
  List<Object?> get props => [
        outgoingInvoicePrefix,
        nextOutgoingInvoiceNumber,
        incomingInvoicePrefix,
        nextIncomingInvoiceNumber,
      ];
}
