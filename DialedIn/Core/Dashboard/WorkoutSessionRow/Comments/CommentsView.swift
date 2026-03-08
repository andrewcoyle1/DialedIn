//
//  CommentsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 08/03/2026.
//

import SwiftUI

struct CommentsDelegate {
    let session: WorkoutSessionModel
}

struct CommentsView: View {

    @State var presenter: CommentsPresenter

    var body: some View {
        List {
            Section {
                if presenter.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if presenter.comments.isEmpty {
                    Text("No comments yet. Be the first!")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(presenter.comments) { comment in
                        commentRow(comment)
                            .swipeActions(edge: .trailing) {
                                if presenter.isOwnComment(comment) {
                                    Button {
                                        presenter.onDeletePressed(comment)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .tint(.red)
                                    }
                                } else {
                                    Button {
                                        
                                    } label: {
                                        Label("Report", systemImage: "flag.fill")
                                    }
                                }
                            }
                    }
                }
            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .safeAreaInset(edge: .bottom) {
            inputBar
        }
    }

    private func commentRow(_ comment: WorkoutSessionComment) -> some View {
        HStack {
            ImageLoaderView(urlString: comment.authorImageUrl ?? Constants.randomImage, clipShape: AnyShape(Circle()))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(comment.dateCreated.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(comment.text)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Add a comment…", text: $presenter.commentDraft, axis: .vertical)
                .lineLimit(1...4)
            Button {
                presenter.onSendPressed()
            } label: {
                if presenter.isSending {
                    ProgressView()
                } else {
                    Image(systemName: "paperplane.fill")
                }
            }
            .disabled(
                presenter.commentDraft.trimmingCharacters(in: .whitespaces).isEmpty ||
                presenter.isSending
            )
        }
        .padding()
        .glassEffect(in: .containerRelative)
        .padding()
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: .mock))
    }
}

extension CoreBuilder {
    func commentsView(router: AnyRouter, delegate: CommentsDelegate) -> some View {
        CommentsView(
            presenter: CommentsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }
}
