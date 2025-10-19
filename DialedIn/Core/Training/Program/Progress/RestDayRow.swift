struct RestDayRow: View {
    let date: Date
    
    var body: some View {
        HStack {
            Image(systemName: "moon.zzz.fill")
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Rest Day")
                    .font(.subheadline)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}