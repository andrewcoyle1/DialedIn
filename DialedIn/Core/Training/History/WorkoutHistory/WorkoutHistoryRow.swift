struct WorkoutHistoryRow: View {
    let session: WorkoutSessionModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let endedAt = session.endedAt {
                        Text(session.dateCreated.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        let duration = endedAt.timeIntervalSince(session.dateCreated)
                        Text(Date.formatDuration(duration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}