## EntryEssential - A Flutter Application

This project presents a comprehensive Flutter application designed for efficient gate management at facilities with controlled entry and exit. The application aims to digitize traditional gate management processes, improving accuracy, security, and reporting capabilities.

**Project Overview:**

The Gate Management System (GMS) is designed to streamline the process of vehicle entry and exit at gated facilities. It provides a user-friendly interface for authorized personnel to:

* **Register Vehicles:** Add new vehicle records with registration numbers and owner details.
* **Track Vehicle Movements:**  Record the entry and exit times of vehicles at specific gates.
* **Search for Vehicle Data:** Quickly search for vehicle information based on registration number, owner name, or date.
* **Generate Detailed Reports:** Create reports on vehicle activity, user actions, and gate usage.

**Target Users:**

The GMS primarily targets:

* **Facility Security Personnel:** To manage vehicle access and record entries/exits.
* **Facility Administrators:** To monitor gate activity, generate reports, and manage user accounts.

**Features:**

* **User Authentication:** Secure login for authorized personnel using Firebase Authentication.
* **Vehicle Registration:**  Manage a database of vehicle records with registration numbers, owner details, and associated user information.
* **Gate Management:** Track vehicle movements at multiple gates, recording entry and exit times, and associated gate numbers.
* **Search Functionality:**  Efficiently search for vehicle information based on registration number, owner name, or specific dates.
* **Report Generation:** Generate detailed reports on vehicle activity, including entry/exit times, gate usage, and user actions.
O
**Technology Stack:**

* **Framework:** Flutter
* **Language:** Dart
* **Dependencies:** `firebase_auth`, `cloud_firestore`, `shared_preferences`, `flutter_localizations`, and other standard Flutter packages.
* **Architecture:** Model-View-ViewModel (MVVM)

**Screenshots:**

* **Admin Access Screen:** ![admin](https://github.com/vedantbhawnani/EntryEssential/assets/104969397/8bcc5d3f-4231-4d15-91fc-d7046ac4b759 width="300")
    * Displays buttons for adding new vehicles, updating vehicle records, deleting vehicles, and adding new users.
* **Gate Management Screen:** ![homepage](https://github.com/vedantbhawnani/EntryEssential/assets/104969397/5fb49c11-705b-4340-8352-5fbd48dce2eb)
    * Shows the active gate (e.g., Gate 1), vehicle count, and buttons for cancelling entry, deleting entries, and searching for vehicles.
* **Search Screen:** 
    * Provides a search bar for entering registration numbers and displays results with relevant vehicle and owner information. 
* **Report Screen:** ![reports_page_with_download_button](https://github.com/vedantbhawnani/EntryEssential/assets/104969397/1695b0fd-63da-4fdb-a663-42496ed90daf)
    * Displays a detailed report with vehicle number, entry/exit times, gate number, and associated user information.
* **Login Screen:** <img src="login_screen.png" width="300">![loginpage](https://github.com/vedantbhawnani/EntryEssential/assets/104969397/eb03bf47-1af4-4aa4-8d96-bc112958d0c4)
    * Allows users to enter their email address and password to authenticate.

**Future Development:**

* **Real-time Updates:** Integrate real-time updates to reflect changes in gate status and vehicle movements.
* **Integration with Existing Systems:**  Integrate with security systems, payment gateways, or other relevant systems for enhanced functionality.
* **Advanced Analytics:**  Develop advanced analytics dashboards to provide insights into traffic patterns, peak hours, and user behavior.

**Contributions:**

We welcome contributions to enhance the Gate Management System! Feel free to open an issue or submit a pull request with any bug fixes, feature suggestions, or improvements.

**Contact:**

[Your GitHub Username]

**Note:**

Remember to replace the placeholder filenames with the actual filenames of your screenshots. You can add or remove sections as needed based on your project's specific details. 
