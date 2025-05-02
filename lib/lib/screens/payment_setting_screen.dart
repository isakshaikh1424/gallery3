// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// class AppConfig {
//   static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY';
// }
//
// class PaymentMethod {
//   final String id;
//   final String name;
//   final String type;
//   final String? maskedInfo;
//
//   const PaymentMethod({
//     required this.id,
//     required this.name,
//     required this.type,
//     this.maskedInfo,
//   });
//
//   // factory PaymentMethod.fromFirestore(DocumentSnapshot doc) {
//   //   final data = doc.data() as Map<String, dynamic>;
//   //   return PaymentMethod(
//   //     id: doc.id,
//   //     name: data['name'] ?? '',
//   //     type: data['type'] ?? '',
//   //     maskedInfo: data['maskedInfo'],
//   //   );
//   // }
//
//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'type': type,
//     'maskedInfo': maskedInfo,
//   };
// }
//
// abstract class PaymentEvent extends Equatable {
//   const PaymentEvent();
//   @override
//   List<Object> get props => [];
// }
//
// class LoadPaymentMethods extends PaymentEvent {}
//
// class AddPaymentMethod extends PaymentEvent {
//   final PaymentMethod method;
//   const AddPaymentMethod(this.method);
//   @override
//   List<Object> get props => [method];
// }
//
// class DeletePaymentMethod extends PaymentEvent {
//   final String id;
//   const DeletePaymentMethod(this.id);
//   @override
//   List<Object> get props => [id];
// }
//
// abstract class PaymentState extends Equatable {
//   const PaymentState();
//   @override
//   List<Object> get props => [];
// }
//
// class PaymentInitial extends PaymentState {}
//
// class PaymentLoading extends PaymentState {}
//
// class PaymentLoaded extends PaymentState {
//   final List<PaymentMethod> methods;
//   const PaymentLoaded(this.methods);
//   @override
//   List<Object> get props => [methods];
// }
//
// class PaymentError extends PaymentState {
//   final String message;
//   const PaymentError(this.message);
//   @override
//   List<Object> get props => [message];
// }
//
// class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
//   final FirebaseFirestore _firestore;
//   final FirebaseAuth _auth;
//
//   PaymentBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
//     : _firestore = firestore ?? FirebaseFirestore.instance,
//       _auth = auth ?? FirebaseAuth.instance,
//       super(PaymentInitial()) {
//     on<LoadPaymentMethods>(_loadMethods);
//     on<AddPaymentMethod>(_addMethod);
//     on<DeletePaymentMethod>(_deleteMethod);
//   }
//
//   Future<void> _loadMethods(
//     LoadPaymentMethods event,
//     Emitter<PaymentState> emit,
//   ) async {
//     try {
//       emit(PaymentLoading());
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');
//
//       final snapshot =
//           await _firestore
//               .collection('users')
//               .doc(user.uid)
//               .collection('paymentMethods')
//               .get();
//
//       final methods =
//           snapshot.docs.map((doc) => PaymentMethod.fromFirestore(doc)).toList();
//
//       emit(PaymentLoaded(methods));
//     } catch (e) {
//       emit(PaymentError('Failed to load methods: ${e.toString()}'));
//     }
//   }
//
//   Future<void> _addMethod(
//     AddPaymentMethod event,
//     Emitter<PaymentState> emit,
//   ) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');
//
//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('paymentMethods')
//           .add(event.method.toJson());
//
//       add(LoadPaymentMethods());
//     } catch (e) {
//       emit(PaymentError(e.toString()));
//     }
//   }
//
//   Future<void> _deleteMethod(
//     DeletePaymentMethod event,
//     Emitter<PaymentState> emit,
//   ) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');
//
//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('paymentMethods')
//           .doc(event.id)
//           .delete();
//
//       add(LoadPaymentMethods());
//     } catch (e) {
//       emit(PaymentError(e.toString()));
//     }
//   }
// }
//
// class PaymentValidators {
//   static String? validateName(String? value, bool isUPI) {
//     if (value == null || value.isEmpty) {
//       return isUPI ? 'UPI ID required' : 'Name required';
//     }
//     if (isUPI && !value.contains('@')) return 'Invalid UPI ID format';
//     if (!isUPI && value.length < 3) return 'Minimum 3 characters';
//     return null;
//   }
//
//   static String? validateCardNumber(String? value) {
//     final cleaned = value?.replaceAll(' ', '') ?? '';
//     if (cleaned.isEmpty) return 'Card number required';
//     if (cleaned.length != 16) return '16 digits required';
//     if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) return 'Numbers only';
//     return null;
//   }
//
//   static String? validateExpiry(String? value) {
//     if (value == null || value.isEmpty) return 'Expiry required';
//     if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return 'MM/YY format';
//     return null;
//   }
//
//   static String? validateCVV(String? value) {
//     if (value == null || value.isEmpty) return 'CVV required';
//     if (value.length != 3) return '3 digits required';
//     return null;
//   }
// }
//
// class CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final text = newValue.text.replaceAll(' ', '');
//     final buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       if ((i + 1) % 4 == 0 && i != text.length - 1) buffer.write(' ');
//     }
//     return TextEditingValue(
//       text: buffer.toString(),
//       selection: TextSelection.collapsed(offset: buffer.length),
//     );
//   }
// }
//
// class ExpiryDateFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final text = newValue.text.replaceAll('/', '');
//     final buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       if (i == 2) buffer.write('/');
//       buffer.write(text[i]);
//     }
//     return TextEditingValue(
//       text: buffer.toString(),
//       selection: TextSelection.collapsed(offset: buffer.length),
//     );
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(
//     BlocProvider<PaymentBloc>(
//       // Added explicit type parameter
//       create: (context) => PaymentBloc(),
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//       home: const PaymentSettingsScreen(),
//     );
//   }
// }
//
// class PaymentSettingsScreen extends StatefulWidget {
//   const PaymentSettingsScreen({super.key});
//
//   @override
//   State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
// }
//
// class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
//   late Razorpay _razorpay;
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _cardController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();
//   String _paymentType = 'card';
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<PaymentBloc>().add(LoadPaymentMethods());
//     });
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     setState(() => _isLoading = false);
//     final method = PaymentMethod(
//       id: response.paymentId!,
//       name: _nameController.text,
//       type: _paymentType,
//       maskedInfo:
//           _paymentType == 'card'
//               ? '**** ${_cardController.text.substring(15)}'
//               : _nameController.text,
//     );
//     context.read<PaymentBloc>().add(AddPaymentMethod(method));
//     _resetForm();
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Payment failed: ${response.message}'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('External wallet selected: ${response.walletName}'),
//       ),
//     );
//   }
//
//   void _resetForm() {
//     _formKey.currentState?.reset();
//     _nameController.clear();
//     _cardController.clear();
//     _expiryController.clear();
//     _cvvController.clear();
//   }
//
//   void _submitForm() {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);
//
//     final options = {
//       'key': AppConfig.razorpayKeyId,
//       'amount': 100,
//       'name': 'Payment Demo',
//       'description': 'Add Payment Method',
//       'prefill': {'contact': '8888888888', 'email': 'user@example.com'},
//     };
//
//     if (_paymentType == 'card') {
//       options['method'] = 'card';
//       options['card[number]'] = _cardController.text.replaceAll(' ', '');
//       options['card[expiry]'] = _expiryController.text.replaceAll('/', '');
//       options['card[cvv]'] = _cvvController.text;
//     }
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Payment Methods'),
//         backgroundColor: Colors.white,
//       ),
//       body: BlocConsumer<PaymentBloc, PaymentState>(
//         listener: (context, state) {
//           if (state is PaymentError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is PaymentLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is PaymentLoaded) {
//             return Column(
//               children: [
//                 Expanded(
//                   child:
//                       state.methods.isEmpty
//                           ? const Center(
//                             child: Text('No payment methods added yet'),
//                           )
//                           : ListView.builder(
//                             itemCount: state.methods.length,
//                             itemBuilder:
//                                 (context, index) => _PaymentMethodCard(
//                                   method: state.methods[index],
//                                   onDelete:
//                                       () => context.read<PaymentBloc>().add(
//                                         DeletePaymentMethod(
//                                           state.methods[index].id,
//                                         ),
//                                       ),
//                                 ),
//                           ),
//                 ),
//                 _PaymentForm(
//                   formKey: _formKey,
//                   paymentType: _paymentType,
//                   nameController: _nameController,
//                   cardController: _cardController,
//                   expiryController: _expiryController,
//                   cvvController: _cvvController,
//                   isLoading: _isLoading,
//                   onTypeChanged: (type) => setState(() => _paymentType = type),
//                   onSubmit: _submitForm,
//                 ),
//               ],
//             );
//           }
//
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
// }
//
// class _PaymentMethodCard extends StatelessWidget {
//   final PaymentMethod method;
//   final VoidCallback onDelete;
//
//   const _PaymentMethodCard({required this.method, required this.onDelete});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             method.type == 'card' ? Icons.credit_card : Icons.account_balance,
//             color: Colors.blue,
//           ),
//         ),
//         title: Text(method.name),
//         subtitle: Text(method.maskedInfo ?? ''),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.red),
//           onPressed:
//               () => showDialog(
//                 context: context,
//                 builder:
//                     (context) => AlertDialog(
//                       title: const Text('Delete Method?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             onDelete();
//                             Navigator.pop(context);
//                           },
//                           child: const Text(
//                             'Delete',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//               ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PaymentForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final String paymentType;
//   final TextEditingController nameController;
//   final TextEditingController cardController;
//   final TextEditingController expiryController;
//   final TextEditingController cvvController;
//   final bool isLoading;
//   final ValueChanged<String> onTypeChanged;
//   final VoidCallback onSubmit;
//
//   const _PaymentForm({
//     required this.formKey,
//     required this.paymentType,
//     required this.nameController,
//     required this.cardController,
//     required this.expiryController,
//     required this.cvvController,
//     required this.isLoading,
//     required this.onTypeChanged,
//     required this.onSubmit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: RadioListTile(
//                     title: const Text('Card'),
//                     value: 'card',
//                     groupValue: paymentType,
//                     onChanged: (value) => onTypeChanged(value!),
//                   ),
//                 ),
//                 Expanded(
//                   child: RadioListTile(
//                     title: const Text('UPI'),
//                     value: 'upi',
//                     groupValue: paymentType,
//                     onChanged: (value) => onTypeChanged(value!),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 labelText: paymentType == 'upi' ? 'UPI ID' : 'Cardholder Name',
//                 prefixIcon: Icon(
//                   paymentType == 'upi'
//                       ? Icons.account_balance
//                       : Icons.person_outline,
//                 ),
//               ),
//               validator:
//                   (value) => PaymentValidators.validateName(
//                     value,
//                     paymentType == 'upi',
//                   ),
//             ),
//             if (paymentType == 'card') ...[
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: cardController,
//                 decoration: const InputDecoration(
//                   labelText: 'Card Number',
//                   prefixIcon: Icon(Icons.credit_card),
//                   hintText: '1234 5678 9012 3456',
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   CardNumberFormatter(),
//                 ],
//                 validator: PaymentValidators.validateCardNumber,
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: expiryController,
//                       decoration: const InputDecoration(
//                         labelText: 'Expiry (MM/YY)',
//                         prefixIcon: Icon(Icons.calendar_today),
//                         hintText: 'MM/YY',
//                       ),
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         ExpiryDateFormatter(),
//                       ],
//                       validator: PaymentValidators.validateExpiry,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: cvvController,
//                       decoration: const InputDecoration(
//                         labelText: 'CVV',
//                         prefixIcon: Icon(Icons.lock),
//                         hintText: '123',
//                       ),
//                       keyboardType: TextInputType.number,
//                       obscureText: true,
//                       validator: PaymentValidators.validateCVV,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: isLoading ? null : onSubmit,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child:
//                   isLoading
//                       ? const CircularProgressIndicator()
//                       : const Text('Add Payment Method'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
