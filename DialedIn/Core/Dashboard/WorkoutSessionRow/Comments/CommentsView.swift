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
            if presenter.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .removeListRowFormatting()
            } else if presenter.comments.isEmpty {
                ContentUnavailableView(
                    "No comments yet",
                    systemImage: "tray",
                    description:
                        Text("Start the conversation.")
                            .font(.caption)
                    
                )
                .removeListRowFormatting()
            } else {
                Section {
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
                                        presenter.onReportPressed(comment)
                                    } label: {
                                        Label("Report", systemImage: "flag.fill")
                                            .tint(.orange)
                                    }
                                }
                            }
                    }
                    .listSectionMargins(.top, 0)
                    
                }
            }
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
            // `Constants.randomImage` was the fallback here, so a commenter with no picture was
            // given someone else's at random, and a different one on every redraw.
            UserAvatarView(imageUrl: comment.authorImageUrl, size: 40)
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

// MARK: - Previews

/// The shipped mock comments all sit on `session-1`, which is the *oldest* mock session, so a
/// preview built straight from `DevPreview` renders the empty state. These previews register a
/// comments service scoped to the session actually being shown.
@MainActor
private func commentsPreviewContainer(
    comments: [WorkoutSessionComment]?,
    delay: Double = 0.0,
    showError: Bool = false
) -> DependencyContainer {
    let container = DevPreview.shared.container()
    container.register(
        CommentsManager.self,
        service: CommentsManager(
            service: MockCommentsService(comments: comments, delay: delay, showError: showError)
        )
    )
    return container
}

#Preview("Comments") {
    let session = WorkoutSessionModel.mock
    let container = commentsPreviewContainer(comments: WorkoutSessionComment.mocks(sessionId: session.id))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: session))
    }
}

#Preview("Empty") {
    let session = WorkoutSessionModel.mock
    let container = commentsPreviewContainer(comments: [])
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: session))
    }
}

#Preview("Loading") {
    let session = WorkoutSessionModel.mock
    let container = commentsPreviewContainer(
        comments: WorkoutSessionComment.mocks(sessionId: session.id),
        delay: 60
    )
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: session))
    }
}

/// A failed fetch currently falls back to an empty list, so this renders the same as `Empty` —
/// worth keeping visible, because it means a network failure is indistinguishable from
/// "no comments yet" for the user.
#Preview("Load Failed") {
    let session = WorkoutSessionModel.mock
    let container = commentsPreviewContainer(comments: nil, showError: true)
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: session))
    }
}

#Preview("Draft Typed") {
    let session = WorkoutSessionModel.mock
    let comments = WorkoutSessionComment.mocks(sessionId: session.id)
    let container = commentsPreviewContainer(comments: comments)
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        CommentsView(
            presenter: CommentsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: builder),
                delegate: CommentsDelegate(session: session)
            )
            .withPreviewState(comments: comments, draft: "Nice work — what did that top single feel like?")
        )
    }
}

#Preview("Sending") {
    let session = WorkoutSessionModel.mock
    let comments = WorkoutSessionComment.mocks(sessionId: session.id)
    let container = commentsPreviewContainer(comments: comments)
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        CommentsView(
            presenter: CommentsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: builder),
                delegate: CommentsDelegate(session: session)
            )
            .withPreviewState(comments: comments, isSending: true)
        )
    }
}

#Preview("Long List") {
    let session = WorkoutSessionModel.mock
    let container = commentsPreviewContainer(comments: WorkoutSessionComment.manyMocks(sessionId: session.id))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    RouterView { router in
        builder.commentsView(router: router, delegate: CommentsDelegate(session: session))
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
