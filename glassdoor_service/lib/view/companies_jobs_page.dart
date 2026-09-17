import 'package:glassdoor_service/service/glassdoor_service.dart';
import 'package:flutter/material.dart';

class CompaniesJobsPage extends StatefulWidget {
  const CompaniesJobsPage({super.key});

  @override
  State<CompaniesJobsPage> createState() => _CompaniesJobsPageState();
}

class _CompaniesJobsPageState extends State<CompaniesJobsPage> {
  String? campo;
  String funcao = 'ANY'; 
  String? _inputError;
  final apiService = GlassdoorService(); // Instância do seu service

  final List<String> jobFunctions = [
    'ANY',
    'ADMINISTRATIVE',
    'ARTS_AND_DESIGN',
    'BUSINESS',
    'CONSULTING',
    'CUSTOMER_SERVICES_AND_SUPPORT',
    'EDUCATION',
    'ENGINEERING',
    'FINANCE_AND_ACCOUNTING',
    'HEALTHCARE',
    'HUMAN_RESOURCES',
    'INFORMATION_TECHNOLOGY',
    'LEGAL',
    'MARKETING',
    'MEDIA_AND_COMMUNICATIONS',
    'MILITARY_AND_PROTECTIVE_SERVICES',
    'OPERATIONS',
    'OTHER',
    'PRODUCT_AND_PROJECT_MANAGEMENT',
    'RESEARCH_AND_SCIENCE',
    'RETAIL_AND_FOOD_SERVICES',
    'SALES',
    'SKILLED_LABOR_AND_MANUFACTURING',
    'TRANSPORTATION',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Pesquise por uma empresa pelo ID (use a página de reviews para encontrar o ID da empresa)",
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                errorText: _inputError,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (value) {
                try {
                  final companyId = glassdoorValidation.validateId(value);
                  setState(() {
                    campo = companyId;
                    _inputError = null;
                  });
                } on glassdoorApiException catch (error) {
                  setState(() {
                    campo = null;
                    _inputError = error.message;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            // Select/Dropdown para o job_function
            DropdownButtonFormField<String>(
              value: funcao,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Área / Job Function",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              items: jobFunctions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    funcao = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: campo == null ? null : apiService.buscaJob(campo!, jobFunction: funcao),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    case ConnectionState.none:
                      return const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Digite um ID de empresa para pesquisar.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'Nenhum job encontrado.',
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        return exibeResultado(context, snapshot);
                      }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exibeResultado(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.data is! Map || (snapshot.data as Map).isEmpty) {
      return const Text(
        'Nenhum job encontrado.',
        style: TextStyle(color: Colors.white),
      );
    }

    final data = Map<String, dynamic>.from(snapshot.data as Map);
    final List<dynamic> jobsList = data['data']?['jobs'] ?? [];

    if (jobsList.isEmpty) {
      return const Text(
        'Nenhum job encontrado.',
        style: TextStyle(color: Colors.white),
      );
    }

    return ListView.builder(
      itemCount: jobsList.length,
      itemBuilder: (context, index) {
        final job = Map<String, dynamic>.from(jobsList[index]);
        final vaga = glassdoorApiService.parseJobResponse(job);

        final vagaCompleta = [
          vaga['job_title'] ?? '',
          vaga['company_name'] ?? '',
          vaga['job_link'] ?? ''
        ].join('\n');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            vagaCompleta,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            softWrap: true,
          ),
        );
      },
    );
  }
}