import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DailyRecord.date, order: .reverse) private var records: [DailyRecord]
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("成长历程")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("记录你每一个准时醒来的清晨")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                if records.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "sun.haze")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.2))
                        Text("尚无挑战记录")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(records) { record in
                                HistoryRow(record: record)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let record: DailyRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(record.status == .success ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: record.status == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(record.status == .success ? .green : .red)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(date: .long, time: .omitted))
                    .font(.system(size: 16, weight: .medium))
                Text(record.status == .success ? "挑战成功" : "挑战失败")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("\(record.status == .success ? "+" : "-")\(record.betAmount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(record.status == .success ? .green : .red)
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 12))
                    .foregroundColor(record.status == .success ? .green : .red)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
        )
    }
}
