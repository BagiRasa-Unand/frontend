import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/claim.dart';
import 'claim_decision_sheet.dart';
import 'claim_status_badge.dart';

class IncomingClaimRow extends StatelessWidget {
  const IncomingClaimRow({
    super.key,
    required this.claim,
    this.queuePosition,
  });

  final Claim claim;
  final int? queuePosition;

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  @override
  Widget build(BuildContext context) {
    final isMenunggu = claim.status == ClaimStatus.menunggu;
    final isAntre = claim.status == ClaimStatus.antre;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      claim.claimantName.isNotEmpty
                          ? claim.claimantName[0].toUpperCase()
                          : 'U',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.primaryDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.claimantName,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Diajukan pukul ${_formatTime(claim.createdAt)}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              ClaimStatusBadge(status: claim.status),
            ],
          ),
          const SizedBox(height: 8),

          // Porsi request info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Permintaan: ${claim.quantity} porsi',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (isAntre)
                Text(
                  'Posisi Antrean: #${queuePosition ?? 1}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Action row
          if (isMenunggu) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Button Tolak
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => showClaimDecisionSheet(context, claim, ClaimDecision.reject),
                  child: Text(
                    'TOLAK',
                    style: AppTextStyles.miniButton.copyWith(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Button Terima
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => showClaimDecisionSheet(context, claim, ClaimDecision.accept),
                  child: Text(
                    'TERIMA',
                    style: AppTextStyles.miniButton.copyWith(
                      color: AppColors.surface,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isAntre) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Menunggu di antrean. Otomatis naik ke antrean aktif jika ada penolakan atau pembatalan.',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (claim.decidedAt != null)
              Text(
                'Diputuskan pada ${_formatTime(claim.decidedAt!)}',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

