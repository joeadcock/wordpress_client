require "spec_helper"

module Wpclient
  describe PaginatedCollection do
    it "wraps an array" do
      list = ["one"]
      pagination = PaginatedCollection.new(list, total: 1, per_page: 1, current_page: 1)

      expect(pagination.each.to_a).to eq list
      expect(pagination.to_a).to eq list
      expect(pagination.to_ary).to eq list

      expect(pagination.total).to eq 1
      expect(pagination.per_page).to eq 1
      expect(pagination.current_page).to eq 1
    end

    it "can be coerced into an array" do
      pagination = PaginatedCollection.new([1], total: 1, per_page: 1, current_page: 1)
      expect([2] + pagination).to eq [2, 1]
    end

    it "is enumerable" do
      expect(
        PaginatedCollection.new([], total: 0, per_page: 1, current_page: 1)
      ).to be_kind_of(Enumerable)
    end

    it "is as large as the array" do
      expect(
        PaginatedCollection.new([1, 2, 3], total: 0, per_page: 1, current_page: 1).size
      ).to eq 3
    end

    it "allows replacement of the entries list" do
      # Useful if you want to decorate the entries, or something along those
      # lines.
      collection = PaginatedCollection.new([1, 2, 3], total: 3, per_page: 10, current_page: 1)
      collection.replace(collection.map { |n| n * 2 })
      expect(collection.to_a).to eq [2, 4, 6]
    end

    describe "pagination attributes" do
      def collection(total: 1, per_page: 1, current_page: 1)
        PaginatedCollection.new([], total: total, per_page: per_page, current_page: current_page)
      end

      it "includes total pages" do
        expect(collection(total: 10, per_page: 5).total_pages).to eq 2
        expect(collection(total: 11, per_page: 5).total_pages).to eq 3
        expect(collection(total:  0, per_page: 5).total_pages).to eq 0
        expect(collection(total: 10, per_page: 0).total_pages).to eq 0
        expect(collection(total:  2, per_page: 9).total_pages).to eq 1
      end

      it "includes next page number" do
        expect(collection(total: 10, per_page: 1, current_page:  1).next_page).to eq 2
        expect(collection(total: 10, per_page: 1, current_page:  9).next_page).to eq 10
        expect(collection(total: 10, per_page: 1, current_page: 10).next_page).to eq nil

        expect(collection(total: 10, per_page: 0, current_page: 1).next_page).to eq nil
      end

      it "includes previous page number" do
        expect(collection(total: 10, per_page: 1, current_page: 10).previous_page).to eq 9
        expect(collection(total: 10, per_page: 1, current_page:  2).previous_page).to eq 1
        expect(collection(total: 10, per_page: 1, current_page:  1).previous_page).to eq nil
      end

      it "is out of bounds if current page is after last page" do
        expect(collection(total: 2, per_page: 1, current_page: 1)).to_not be_out_of_bounds
        expect(collection(total: 2, per_page: 1, current_page: 2)).to_not be_out_of_bounds

        expect(collection(total: 2, per_page: 1, current_page: 3)).to be_out_of_bounds
        expect(collection(total: 2, per_page: 1, current_page: 0)).to be_out_of_bounds
      end
    end
  end
end
