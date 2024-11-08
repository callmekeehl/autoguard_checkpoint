import 'package:autoguard_flutter/Constant.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Pour le formatage des dates

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Appointment> _appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAppointments();
  }

  // Fonction pour récupérer les rendez-vous de l'utilisateur depuis le backend
  Future<void> _loadUserAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? utilisateurId = prefs.getInt('userId');
    String? token = prefs.getString('authToken');

    if (utilisateurId == null || token == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('$url/api/rdvs/utilisateurs/$utilisateurId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Appointment> appointments = data.map((rdv) {
        // méthode de parsing correcte pour les dates
        DateTime date =
            _parseDate(rdv['date']); // Récupération de la date et le parsing
        return Appointment(
          startTime: date,
          endTime: date.add(Duration(hours: 1)), // Durée du rendez-vous
          subject: rdv['motif'], // Sujet ou motif du RDV
          color: Colors.orange,
        );
      }).toList();

      setState(() {
        _appointments = appointments;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour parser correctement la date au format "Tue, 06 Aug 2024 00:00:00 GMT"
  DateTime _parseDate(String dateStr) {
    return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
        .parseUtc(dateStr)
        .toLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Calendrier des RDV',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SfCalendar(
              view: CalendarView.month,
              dataSource: AppointmentDataSource(_appointments),
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                agendaStyle: AgendaStyle(
                  appointmentTextStyle:
                      TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
    );
  }
}

// Classe de gestion des données des rendez-vous pour le calendrier
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
