require 'spec_helper'

module Synapse
  module Serialization
    
    describe OxDocumentToXmlConverter, ox: true do
      it 'converts an Ox document to an XML string' do
        converter = OxDocumentToXmlConverter.new

        converter.source_type.should == Ox::Document
        converter.target_type.should == String

        input = Ox::Document.new
        output = converter.convert_content input

        output.class.should == String
      end
    end
    describe XmlToOxDocumentConverter, ox: true do
      it 'converts an XML string to an Ox document' do
        converter = XmlToOxDocumentConverter.new
        
        converter.source_type.should == String
        converter.target_type.should == Ox::Document

        output = converter.convert_content '<?xml?>'
        
        output.class.should == Ox::Document
      end
    end
    
  end
end
