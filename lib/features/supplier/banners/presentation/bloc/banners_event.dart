import 'package:equatable/equatable.dart';

import '../../domain/entities/banner_entity.dart';

abstract class BannersEvent extends Equatable {
  const BannersEvent();

  @override
  List<Object?> get props => [];
}

class LoadBannersRequested extends BannersEvent {
  const LoadBannersRequested();
}

class CreateBannerRequested extends BannersEvent {
  final BannerEntity banner;

  const CreateBannerRequested(this.banner);

  @override
  List<Object?> get props => [banner];
}

class UpdateBannerRequested extends BannersEvent {
  final BannerEntity banner;

  const UpdateBannerRequested(this.banner);

  @override
  List<Object?> get props => [banner];
}

class DeleteBannerRequested extends BannersEvent {
  final String bannerId;

  const DeleteBannerRequested(this.bannerId);

  @override
  List<Object?> get props => [bannerId];
}

class ClearBannerMessageRequested extends BannersEvent {
  const ClearBannerMessageRequested();
}