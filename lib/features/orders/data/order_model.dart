import 'package:flutter/material.dart';

import '../../../core/constants/mosaed_colors.dart';

class ServiceOrder {
  const ServiceOrder({
    required this.id,
    required this.serviceKey,
    required this.statusKey,
    required this.statusColor,
    required this.workerName,
    required this.workerRating,
    required this.workerJobsCount,
    required this.agreedAmount,
    required this.paymentReceived,
    required this.scheduledSlot,
    required this.locationText,
    required this.arrivedAt,
    required this.finishedAt,
    required this.toolsUsed,
    required this.materialsUsed,
    required this.customerRating,
    required this.notes,
  });

  final String id;
  final String serviceKey;
  final String statusKey;
  final Color statusColor;
  final String workerName;
  final double workerRating;
  final int workerJobsCount;
  final double agreedAmount;
  final bool paymentReceived;
  final String scheduledSlot;
  final String locationText;
  final String arrivedAt;
  final String finishedAt;
  final List<String> toolsUsed;
  final List<String> materialsUsed;
  final double customerRating;
  final String notes;

  static List<ServiceOrder> sampleOrders() => [
        ServiceOrder(
          id: '#1024',
          serviceKey: 'mosaedPlumbing',
          statusKey: 'mosaedOrderActive',
          statusColor: MosaedColors.primary,
          workerName: 'أحمد الغامدي',
          workerRating: 4.8,
          workerJobsCount: 126,
          agreedAmount: 180,
          paymentReceived: false,
          scheduledSlot: 'mosaedSlotToday4',
          locationText: 'الرياض • النرجس • شارع الأمير',
          arrivedAt: 'mosaedArrivedAt1024',
          finishedAt: 'mosaedNotFinishedYet',
          toolsUsed: ['mosaedToolWrench', 'mosaedToolPipe'],
          materialsUsed: ['mosaedMaterialSeal', 'mosaedMaterialPipeJoint'],
          customerRating: 0,
          notes: 'mosaedOrderNote1024',
        ),
        ServiceOrder(
          id: '#1021',
          serviceKey: 'mosaedElectric',
          statusKey: 'mosaedOrderDone',
          statusColor: MosaedColors.success,
          workerName: 'سعد الحربي',
          workerRating: 4.9,
          workerJobsCount: 214,
          agreedAmount: 250,
          paymentReceived: true,
          scheduledSlot: 'mosaedSlotYesterday6',
          locationText: 'الرياض • الياسمين • شارع التخصصي',
          arrivedAt: 'mosaedArrivedAt1021',
          finishedAt: 'mosaedFinishedAt1021',
          toolsUsed: ['mosaedToolTester', 'mosaedToolDrill'],
          materialsUsed: ['mosaedMaterialBreaker', 'mosaedMaterialCable'],
          customerRating: 5,
          notes: 'mosaedOrderNote1021',
        ),
        ServiceOrder(
          id: '#1018',
          serviceKey: 'mosaedInsulation',
          statusKey: 'mosaedOrderPending',
          statusColor: const Color(0xFFF59E0B),
          workerName: 'mosaedWorkerPending',
          workerRating: 0,
          workerJobsCount: 0,
          agreedAmount: 420,
          paymentReceived: false,
          scheduledSlot: 'mosaedSlotTomorrow10',
          locationText: 'الرياض • الملقا • شارع أنس',
          arrivedAt: 'mosaedNotArrivedYet',
          finishedAt: 'mosaedNotFinishedYet',
          toolsUsed: [],
          materialsUsed: [],
          customerRating: 0,
          notes: 'mosaedOrderNote1018',
        ),
      ];

  static ServiceOrder? findById(String id) {
    try {
      return sampleOrders().firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }
}
