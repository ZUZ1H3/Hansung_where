import 'package:flutter/material.dart';
import '../DbConn.dart';
import '/ReportCard.dart';
import '../Report.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 뒤로 가기
                  },
                  child: const Icon(
                    Icons.arrow_back, // 뒤로 가기 아이콘
                    size: 24,
                  ),
                ),
                const Text(
                  '신고 내역',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24), // 오른쪽 여백 확보 (아이콘이 없으므로 빈 공간 추가)
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildReportList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    return FutureBuilder<List<Report>>(
      future: DbConn.getReports(), // 신고 데이터를 가져오는 Future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('신고 내역이 없습니다.'));
        } else {
          List<Report> reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ReportCard(
                report: reports[index], // ReportCard에 데이터 전달
              );
            },
          );
        }
      },
    );
  }
}
