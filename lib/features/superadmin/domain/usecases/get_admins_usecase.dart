/// GET ADMINS USECASE
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_management_repository.dart';

class GetAdminsUsecase {
  final UserManagementRepository repository;

  const GetAdminsUsecase(this.repository);

  Future<Either<Failure, PaginatedUsers>> call({UserFilters? filters}) {
    return repository.getAdmins(filters: filters);
  }
}
