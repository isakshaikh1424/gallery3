import 'package:flutter/material.dart'; // Import for TimeOfDay
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingState {
  final List<String> selectedTests;
  final DateTime? date;
  final TimeOfDay? time;
  final bool homeCollection;

  BookingState({
    required this.selectedTests,
    this.date,
    this.time,
    required this.homeCollection,
  });

  BookingState copyWith({
    List<String>? selectedTests,
    DateTime? date,
    TimeOfDay? time,
    bool? homeCollection,
  }) {
    return BookingState(
      selectedTests: selectedTests ?? this.selectedTests,
      date: date ?? this.date,
      time: time ?? this.time,
      homeCollection: homeCollection ?? this.homeCollection,
    );
  }
}

class BookingCubit extends Cubit<BookingState> {
  BookingCubit()
    : super(BookingState(selectedTests: [], homeCollection: false));

  void updateSelectedTests(List<String> tests) {
    emit(state.copyWith(selectedTests: tests));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void updateTime(TimeOfDay time) {
    emit(state.copyWith(time: time));
  }

  void toggleHomeCollection() {
    emit(state.copyWith(homeCollection: !state.homeCollection));
  }

  void confirmBooking(String centerId) {
    // Logic to confirm booking
    // Save booking details to Firestore or API
    print('Booking confirmed at $centerId with details:');
    print('Tests: ${state.selectedTests}');
    print('Date: ${state.date}');
    print('Time: ${state.time}');
    print('Home Collection: ${state.homeCollection}');
  }
}
