require "spec_helper"

module WordpressClient
  describe PaginatedCollection do
    it "wraps an array" do
      list = ["one"]
      pagination = PaginatedCollection.new(list, total: 1, per_page: 1, current_page: 1)

      expect(pagination.each.to_a).to eq list
      expect(pagination.to_a).to eq list
      expect(pagination.size).to eq 1

      expect(pagination.total).to eq 1
      expect(pagination.per_page).to eq 1
      expect(pagination.current_page).to eq 1
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

      # Only to be compatible with will_paginate < 3.0
      it "has an offset" do
        expect(collection(per_page:  5, current_page: 1).offset).to eq 0
        expect(collection(per_page:  5, current_page: 2).offset).to eq 5
        expect(collection(per_page: 50, current_page: 3).offset).to eq 100

        expect(collection(per_page: 50, current_page: 0).offset).to eq 0
        expect(collection(per_page:  0, current_page: 0).offset).to eq 0
      end
    end
  end
end
