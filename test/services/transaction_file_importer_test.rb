require 'test_helper.rb'

class TransactionFileImporterTest < ActiveSupport::TestCase
  def setup
    @importer = TransactionFileImporter.new
    @header = @importer.import(file_fixture('cfd_transaction.dat'), 'cfd123.dat')
  end

  def test_import_creates_transaction_header_record
    assert_difference('TransactionHeader.count', 1) do
      @importer.import(file_fixture('cfd_transaction.dat'), 'cfd123.dat')
    end
  end

  def test_header_has_correct_regime
    assert_equal('CFD', @header.regime.name)
  end

  def test_header_has_correct_region
    assert_equal('E', @header.region)
  end

  def test_header_has_correct_file_type_flag
    assert_equal('I', @header.file_type_flag)
  end

  def test_header_has_correct_file_sequence_number
    assert_equal(358, @header.file_sequence_number)
  end

  def test_header_has_correct_file_date
    assert_equal(Date.new(2015, 1, 20), @header.generated_at.to_date)
  end

  def test_import_creates_transaction_detail_records
    assert_difference('TransactionDetail.count', 2) do
      @importer.import(file_fixture('cfd_transaction.dat'), 'cfd123.dat')
    end
  end

  def test_import_creates_detail_records_with_correct_consent_info
    @header.transaction_details.each do |td|
      assert_equal("071919/1/3", td.reference_1)
      assert_equal("1", td.reference_2)
      assert_equal("3", td.reference_3)
    end
  end

  def test_imported_transactions_have_default_temporary_cessation_value
    @header.transaction_details.each do |transaction|
      assert_equal(false, transaction.temporary_cessation)
    end
  end

  def test_extract_consent_fields_handle_consent_reference
    fields = @importer.extract_consent_fields("Consent No - 27/23/0118/1/2")
    assert_equal(
      {
        reference_1: "27/23/0118/1/2",
        reference_2: "1",
        reference_3: "2"
      },
      fields
    )
  end

  def test_extract_consent_fields_handle_authorisation_consent_reference
    fields = @importer.extract_consent_fields("Authorisation No - WQD005215/1/1")
    assert_equal(
      {
        reference_1: "WQD005215/1/1",
        reference_2: "1",
        reference_3: "1"
      },
      fields
    )
  end

  def test_extract_consent_fields_handle_consent_reference_with_space
    fields = @importer.extract_consent_fields("Consent No - T/40/00817/O */1/2")
    assert_equal(
      {
        reference_1: "T/40/00817/O */1/2",
        reference_2: "1",
        reference_3: "2"
      },
      fields
    )
  end

  def test_import_creates_transactions_with_whitespace_consents
    header = @importer.import(file_fixture('cfd_trans_consents.dat'), 'cfd456.dat')

    assert_equal(2, header.transaction_details.count)

    header.transaction_details.each do |td|
      assert_equal("T/40/00817/O */1/2", td.reference_1)
      assert_equal("1", td.reference_2)
      assert_equal("2", td.reference_3)
    end
  end

end