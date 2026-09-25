import 'package:flutter/material.dart';
import 'package:glassdoor_service/view/jobs_details_page.dart';
import 'package:glassdoor_service/view/companies_jobs_page.dart';
import 'package:glassdoor_service/view/company_job_search.dart';
import 'package:glassdoor_service/view/company_search_page.dart';
import 'package:glassdoor_service/view/company_review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Glassdoor Service"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildMenuItem(
              context: context,
              icon: Icons.business,
              label: "Buscar Empresa",
              page: const CompanySearchPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.reviews,
              label: "Avaliações da Empresa",
              page: const CompanyReviewPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.work,
              label: "Buscar Vagas",
              page: const JobSearchPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.apartment,
              label: "Vagas por Empresa",
              page: const CompanyJobsPage(),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.gif_box,
              label: "Buscar GIF",
              page: const GifSearchPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 50.0),
          const SizedBox(width: 30),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}

