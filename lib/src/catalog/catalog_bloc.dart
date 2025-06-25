
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'models/item.dart';


/// ------ Events ------
sealed class CatalogEvent extends Equatable{
  @override
  List<Object?> get props => [];
}
class LoadCatalog extends CatalogEvent{

}

/// ------ States ------
sealed class CatalogState extends Equatable{
  @override
  List<Object?> get props => [];
}
class CatalogInitial extends CatalogState{}
class CatalogLoading extends CatalogState{}
class CatalogLoaded extends CatalogState{
  final List<Item> items;
  CatalogLoaded(this.items);

  @override
  List<Object?> get props => [items];
}
class CatalogError extends CatalogState{
  final String message;
  CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}


/// ------ Catalog BLoC ------
class CatalogBloc extends Bloc<CatalogEvent,CatalogState>{
  CatalogBloc() : super(CatalogInitial()){
    on<LoadCatalog>(_onLoadCatalog);
  }

  //Load Catalog from assets/catalog.json file
  Future<void> _onLoadCatalog(LoadCatalog event,Emitter<CatalogState> emit) async{
    emit(CatalogLoading());
    try {
      final String jsonString = await rootBundle.loadString('assets/catalog.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Item> items = jsonList
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to load catalog: ${e.toString()}'));
    }
  }

}


