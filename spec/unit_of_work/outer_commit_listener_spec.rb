require 'spec_helper'
require 'unit_of_work/fixtures'

module Synapse
  module UnitOfWork

    describe OuterCommitListener do
      let(:outer_unit) { Object.new }
      let(:inner_unit) { Object.new }
      subject { OuterCommitListener.new inner_unit }

      it 'commits the inner unit once the outer unit is committed' do
        mock(inner_unit).perform_inner_commit
        subject.after_commit outer_unit
      end

      it 'rolls back the inner unit if the outer unit is rolled back' do
        mock(inner_unit).perform_inner_rollback(anything)
        subject.on_rollback outer_unit, MockError.new
      end

      it 'cleans up the inner unit when the outer unit is cleaned up' do
        mock(inner_unit).perform_cleanup
        subject.on_cleanup outer_unit
      end
    end

  end
end
