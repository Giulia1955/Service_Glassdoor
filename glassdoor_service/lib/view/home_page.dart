import 'package:glassdoor_service/view/companies_jobs_page.dart';
import 'package:glassdoor_service/view/companies_review_page.dart';
import 'package:glassdoor_service/view/jobs_details_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Companies Jobs",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PorExtensoPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.home, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Busca CEP",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscaCepPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Tabela FIPE",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TabelaFipepage()),
                );
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.description, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Consulta CNPJ",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsultaCNPJPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.holiday_village, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Feriados",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HolidaysPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}