require 'spec_helper'
require 'process_manager/fixtures'

module Synapse
  module ProcessManager

    describe InMemoryProcessRepository do
      it 'support finding processes by correlations' do
        correlation_a = Correlation.new :order_id, 1
        correlation_b = Correlation.new :order_id, 2

        process_a = Process.new
        process_a.correlations.add correlation_a
        process_b = Process.new
        process_b.correlations.add correlation_b

        repository = InMemoryProcessRepository.new
        repository.add process_a
        repository.add process_b

        repository.find(Process, correlation_a).should include(process_a.id)
        repository.find(Process, correlation_b).should include(process_b.id)
      end

      it 'support loading processes by identifier' do
        repository = InMemoryProcessRepository.new

        process_a = Process.new
        process_b = Process.new

        repository.add process_a
        repository.add process_b

        repository.load(process_a.id).should == process_a
        repository.load(process_b.id).should == process_b
      end

      it 'mark processes as committed' do
        repository = InMemoryProcessRepository.new

        process = StubProcess.new
        repository.commit process

        repository.count.should == 1

        # Make sure the correlation set was marked as committed
        process.correlations.additions.count.should == 0
        process.correlations.deletions.count.should == 0

        process.cause_finish

        repository.commit process
        repository.count.should == 0
      end
    end

  end
end
