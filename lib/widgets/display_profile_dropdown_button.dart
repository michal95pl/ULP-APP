import 'package:flutter/material.dart';

// class DisplayProfileDropdownButton {


//   List<String> profiles;  
//   String currentProfile;

//   DisplayProfileDropdownButton(this.profiles) : currentProfile = profiles.isNotEmpty ? profiles[0] : '';

//   Future<void>? _onChangedFunction;

//   FutureBuilder getDropdownButton(State state, Future<void> onChanged(int val), bool isActive, bool suspend) {
//     return FutureBuilder(
//       future: _onChangedFunction,
//       builder: (context, snapshot) {
//         return DropdownButton<String>(
//           value: currentProfile,
//           onChanged: isActive? (String? value) {
//             if (snapshot.connectionState != ConnectionState.waiting && isActive)
//             {
//               if (!suspend) {
//                 currentProfile = value!;
//                 _onChangedFunction = onChanged(value.index);
//               }
//               // todo: move setState to if statement (may increase performance)
//               state.setState(() {});
//             }
//           } : null,
//           items: EFFECTS.values.map((EFFECTS effect) {
//             return DropdownMenuItem<EFFECTS>(
//               value: effect,
//               child: Text(
//                 effect.toString().split('.').last,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             );
//           }).toList(),
//           dropdownColor: const Color.fromARGB(255, 18, 24, 43),
//         );
//       },
//     );
//   }

//   String getCurrentEffect() {
//     return currentEffect.toString().split('.').last;
//   }
// }