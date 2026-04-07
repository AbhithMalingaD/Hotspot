import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class SpaceSetupPage extends StatefulWidget {
  const SpaceSetupPage({super.key});

  @override
  State<SpaceSetupPage> createState() => _SpaceSetupPageState();
}

class _SpaceSetupPageState extends State<SpaceSetupPage> {
  int    _step       = 1;
  String _spaceName  = '';
  String _location   = '';
  String _capacity   = '';
  String _spaceType  = '';
  String _openTime   = '08:00';
  String _closeTime  = '18:00';
  String _desc       = '';
  String _price      = '';
  final List<File> _photos = [];

  static const _types = [
    'Co-working Hub', 'Private Office',
    'Meeting Rooms', 'Event Space', 'Hybrid',
  ];

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker()
        .pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _photos
          .addAll(picked.map((p) => File(p.path))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(children: [
          // ── Header + progress ────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(children: [
              // Brand
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.adminAccent.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.adminAccent.withOpacity(0.30)),
                ),
                child: const Icon(Icons.wifi_rounded,
                    color: AppColors.adminAccent, size: 22),
              ),
              const SizedBox(height: 10),
              Text('Set Up Your Space',
                  style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Tell us about your workspace',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 20),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final s = i + 1;
                  final done = s < _step;
                  final active = s == _step;
                  return Row(children: [
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.adminAccent.withOpacity(0.20)
                            : done
                                ? AppColors.adminAccent
                                : AppTheme.surfaceVariant(context),
                        border: Border.all(
                          color: active || done
                              ? AppColors.adminAccent.withOpacity(0.50)
                              : Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 14,
                                color: Colors.white)
                            : Text('$s',
                                style: AppTextStyles.label
                                    .copyWith(
                                        color: active
                                            ? AppColors.adminAccent
                                            : AppColors.grey500)),
                      ),
                    ),
                    if (s < 3)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 2,
                        color: done
                            ? AppColors.adminAccent
                            : Colors.white.withOpacity(0.10),
                      ),
                  ]);
                }),
              ),
            ]),
          ),

          // ── Step content ────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.fromLTRB(
                    24, 20, 24, 120),
                child: _stepContent(),
              ),
            ),
          ),

          // ── Buttons ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(children: [
              if (_step > 1)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.20)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                    ),
                    child: Text('Back',
                        style: AppTextStyles.body),
                  ),
                ),
              if (_step > 1) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step < 3) {
                      setState(() => _step++);
                    } else {
                      context
                          .read<AppProvider>()
                          .completeSpaceSetup();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _step == 3 ? 'Launch Space' : 'Continue',
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 1: return _Step1(
          spaceName: _spaceName, location: _location,
          capacity: _capacity, photos: _photos,
          onName: (v) => setState(() => _spaceName = v),
          onLoc:  (v) => setState(() => _location   = v),
          onCap:  (v) => setState(() => _capacity   = v),
          onPickPhotos: _pickPhotos,
          onRemovePhoto: (i) =>
              setState(() => _photos.removeAt(i)),
      );
      case 2: return _Step2(
          spaceType: _spaceType, openTime: _openTime,
          closeTime: _closeTime, desc: _desc,
          price: _price, types: _types,
          onType:  (v) => setState(() => _spaceType  = v),
          onOpen:  (v) => setState(() => _openTime   = v),
          onClose: (v) => setState(() => _closeTime  = v),
          onDesc:  (v) => setState(() => _desc       = v),
          onPriceChanged: (v) => setState(() => _price = v),
      );
      case 3: return _Step3(
          spaceName: _spaceName, location: _location,
          capacity: _capacity, spaceType: _spaceType,
          openTime: _openTime, closeTime: _closeTime,
          desc: _desc, price: _price,
      );
      default: return const SizedBox();
    }
  }
}

// ── Step 1 ───────────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final String spaceName, location, capacity;
  final List<File> photos;
  final ValueChanged<String> onName, onLoc, onCap;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;

  const _Step1({
    required this.spaceName, required this.location,
    required this.capacity, required this.photos,
    required this.onName, required this.onLoc,
    required this.onCap, required this.onPickPhotos,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return _SetupCard(children: [
      _SetupField(
        label: 'Space Name',
        hint: 'e.g. Urban Hub Colombo',
        icon: Icons.business_rounded,
        initial: spaceName,
        onChanged: onName,
      ),
      _SetupField(
        label: 'Location',
        hint: 'e.g. 42 Galle Road, Colombo 03',
        icon: Icons.location_on_outlined,
        initial: location,
        onChanged: onLoc,
      ),
      _SetupField(
        label: 'Total Capacity',
        hint: 'e.g. 50',
        icon: Icons.people_outline_rounded,
        initial: capacity,
        keyboardType: TextInputType.number,
        onChanged: onCap,
      ),
      const SizedBox(height: 8),
      Text('Space Photos', style: AppTextStyles.label
          .copyWith(letterSpacing: 1.5)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onPickPhotos,
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_rounded,
                  color: AppColors.adminAccent, size: 28),
              const SizedBox(height: 6),
              Text('Tap to upload photos',
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500)),
              Text('JPG, PNG up to 5MB',
                  style: AppTextStyles.label),
            ],
          ),
        ),
      ),
      if (photos.isNotEmpty) ...[
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: photos.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) => Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(photos[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: () => onRemovePhoto(i),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54),
                  child: const Icon(Icons.close_rounded,
                      size: 12, color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
      ],
    ]);
  }
}

// ── Step 2 ───────────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final String spaceType, openTime, closeTime, desc;
  final String price;
  final List<String> types;
  final ValueChanged<String> onType, onOpen, onClose, onDesc;
  final ValueChanged<String> onPriceChanged;

  const _Step2({
    required this.spaceType, required this.openTime,
    required this.closeTime, required this.desc,
    required this.price, required this.types,
    required this.onType, required this.onOpen, required this.onClose,
    required this.onDesc, required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SetupCard(children: [
      Text('Space Type', style: AppTextStyles.label
          .copyWith(letterSpacing: 1.5)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: types.map((t) {
        final sel = spaceType == t;
        return GestureDetector(
          onTap: () => onType(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.adminAccent.withOpacity(0.20)
                  : AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel
                    ? AppColors.adminAccent.withOpacity(0.50)
                    : Colors.white.withOpacity(0.10),
              ),
            ),
            child: Text(t,
                style: AppTextStyles.bodySmall.copyWith(
                    color: sel
                        ? AppColors.adminAccent
                        : AppColors.grey400,
                    fontWeight: sel
                        ? FontWeight.w500
                        : FontWeight.w400)),
          ),
        );
      }).toList()),
      const SizedBox(height: 16),
      Text('Operating Hours', style: AppTextStyles.label
          .copyWith(letterSpacing: 1.5)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: _TimeField(
              label: 'Open', value: openTime, onChanged: onOpen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeField(
              label: 'Close', value: closeTime, onChanged: onClose),
        ),
      ]),
      const SizedBox(height: 16),
      Text('Description', style: AppTextStyles.label
          .copyWith(letterSpacing: 1.5)),
      const SizedBox(height: 8),
      TextField(
        maxLines: 3,
        style: AppTextStyles.body,
        onChanged: onDesc,
        decoration: InputDecoration(
          hintText: 'Tell customers about your space...',
          hintStyle: AppTextStyles.body
              .copyWith(color: AppColors.grey500),
          filled: true,
          fillColor: AppTheme.surfaceVariant(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.white.withOpacity(0.10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.white.withOpacity(0.10)),
          ),
        ),
      ),
      if (spaceType.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text('Pricing', style: AppTextStyles.label.copyWith(letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          style: AppTextStyles.body,
          onChanged: onPriceChanged,
          decoration: InputDecoration(
            hintText: 'Price per hour (LKR)',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey500),
            prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
            filled: true,
            fillColor: AppTheme.surfaceVariant(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
            ),
          ),
        ),
      ],
    ]);
  }
}

// ── Step 3 ───────────────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final String spaceName, location, capacity,
               spaceType, openTime, closeTime, desc, price;

  const _Step3({
    required this.spaceName, required this.location,
    required this.capacity, required this.spaceType,
    required this.openTime, required this.closeTime,
    required this.desc, required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Name',        spaceName.isEmpty  ? 'Not set' : spaceName),
      ('Location',    location.isEmpty   ? 'Not set' : location),
      ('Capacity',    capacity.isEmpty   ? 'Not set' : '$capacity seats'),
      ('Type',        spaceType.isEmpty  ? 'Not set' : spaceType),
      ('Hours',       '$openTime – $closeTime'),
    ];

    return Column(children: [
      _SetupCard(children: [
        Text('Review Your Space',
            style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(child: Text(r.$1,
                    style: AppTextStyles.bodySmall)),
                Text(r.$2,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right),
              ]),
            )),
        if (price.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Price per hour',
                style: AppTextStyles.bodySmall)),
            Text('LKR $price',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.right),
          ]),
        ],
        if (desc.isNotEmpty) ...[
          Divider(color: AppTheme.surfaceVariant(context)),
          Text('Description',
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(desc, style: AppTextStyles.body),
        ],
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.adminAccent.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.adminAccent.withOpacity(0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.adminAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Your space will be live on Hotspot after setup. You can update all details from your admin dashboard anytime.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

// ── Shared setup widgets ──────────────────────────────────────────────────────

class _SetupCard extends StatelessWidget {
  final List<Widget> children;
  const _SetupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SetupField extends StatelessWidget {
  final String label, hint, initial;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _SetupField({
    required this.label, required this.hint,
    required this.icon, required this.initial,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label
              .copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initial,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body
                  .copyWith(color: AppColors.grey500),
              prefixIcon:
                  Icon(icon, color: AppColors.grey500, size: 18),
              filled: true,
              fillColor: AppTheme.surfaceVariant(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label, value;
  final ValueChanged<String> onChanged;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final parts = value.split(':');
            final initial = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 8,
              minute: int.tryParse(parts[1]) ?? 0,
            );
            final picked = await showTimePicker(
                context: context, initialTime: initial);
            if (picked != null) {
              final h = picked.hour.toString().padLeft(2, '0');
              final m = picked.minute.toString().padLeft(2, '0');
              onChanged('$h:$m');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.10)),
            ),
            child: Row(children: [
              const Icon(Icons.access_time_rounded,
                  color: AppColors.grey500, size: 14),
              const SizedBox(width: 8),
              Text(value, style: AppTextStyles.body),
            ]),
          ),
        ),
      ],
    );
  }
}