# frozen_string_literal: true

require "spec_helper"
require "cobra_commander/executor"

RSpec.describe CobraCommander::Executor::Execution do
  include ::CobraCommander::Executor::Job

  def success_job(output)
    -> { success(output) }
  end

  def error_job(output)
    -> { error(output) }
  end

  def skip_job(reason)
    -> { skip(reason) }
  end

  it "executes all given jobs" do
    execution = ::CobraCommander::Executor::Execution.new([
                                                            success_job("very good"),
                                                            success_job("okay"),
                                                            success_job("works"),
                                                            error_job("very bad"),
                                                            error_job("poor"),
                                                            error_job("broken"),
                                                          ], workers: 1)

    _, values, errors = execution.wait.result

    expect(values).to eql ["very good", "okay", "works", nil, nil, nil]
    expect(errors).to eql [nil, nil, nil, "very bad", "poor", "broken"]
  end

  it "succeeds with a success key" do
    execution = ::CobraCommander::Executor::Execution.new([
                                                            success_job("very good"),
                                                            -> { [:success, "success output"] },
                                                          ], workers: 1)

    result = execution.wait

    expect(result).to be_fulfilled
    expect(result.value.last).to eql "success output"
  end

  it "succeeds with a returned output" do
    execution = ::CobraCommander::Executor::Execution.new([-> { "success output" }], workers: 1)

    result = execution.wait

    expect(result).to be_fulfilled
    expect(result.value.last).to eql "success output"
  end

  it "succeeds with a returned reason when skip is returned" do
    execution = ::CobraCommander::Executor::Execution.new([skip_job("cant do it right now")], workers: 1)

    result = execution.wait

    expect(result).to be_fulfilled
    expect(result.value.last).to eql "cant do it right now"
  end

  it "fails if a job returns [:error, output]" do
    execution = ::CobraCommander::Executor::Execution.new([
                                                            success_job("very good"),
                                                            success_job("okay"),
                                                            -> { [:error, "error output"] },
                                                          ], workers: 1)

    result = execution.wait

    expect(result).to_not be_fulfilled
    expect(result.reason.last).to eql "error output"
  end

  it "is a hash of job => result" do
    job1 = success_job("very good")
    job2 = success_job("okay")

    execution = ::CobraCommander::Executor::Execution.new([job1, job2], workers: 1)

    expect(execution.keys).to eql [job1, job2]
    expect(execution.values.first).to be_a ::Concurrent::Promises::Future
    expect(execution.values.last).to be_a ::Concurrent::Promises::Future
  end
end
