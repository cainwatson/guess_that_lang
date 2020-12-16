defmodule GuessThatLang.Mocks.CodeSearcher do
  def search_payload_elixir(_opts \\ []) do
    {:ok,
     %{
       language: "Elixir",
       content: "defmodule Hello do
  def world do
    IO.puts(\"Hello, world!\")
  end
end"
     }}
  end

  def search_payload_javascript(_opts \\ []) do
    {:ok,
     %{
       language: "JavaScript",
       content: "const express = require('express')
const app = express()

app.listen(8080, () => console.log('Listening on :8080'))"
     }}
  end

  def search_payload_ruby(_opts \\ []) do
    {:ok,
     %{
       language: "Ruby",
       content: "module Mutations
  class CreateIssue < Mutations::BaseMutation
    description 'Create a new issue.'

    argument :user_creator_id, ID, required: true, loads: Types::UserType
    argument :project_id, ID, required: true, loads: Types::ProjectType
    argument :board_ids, [ID], required: false, default_value: []
    argument :summary, String, required: true
    argument :description, String, required: false

    field :issue, Types::IssueType, null: true
    field :errors, [String], null: true

    def resolve(user_creator:, project:, summary:, board_ids:, **args)
      issue = Projects::Issue.create(
        user_creator: user_creator,
        project: project,
        summary: summary,
        description: args[:description]
      )

      board_ids = board_ids.map { |id| IssueTrackerSchema.object_id_from_id(id) }
      board_items = issue.add_to_boards(board_ids)

      if board_items.any?(&:invalid?)
        { errors: board_items.flat_map(&:errors.full_messages) }
      elsif issue.invalid?
        { errors: issue.errors.full_messages }
      else
        { issue: issue }
      end
    end
  end
end"
     }}
  end
end
