describe Month do
  context "validations" do
    subject(:month) { Month.new }

    describe "number" do
      it { is_expected.to accept_values_for(:number, "201501", "300012") }
      it { is_expected.not_to accept_values_for(:number, nil, "foobar") }

      it "is unique per user" do
        existing_month = create(:month, number: "201504")
        month = build(:month, user: existing_month.user)

        expect(month).to accept_values_for(:number, "201505")
        expect(month).not_to accept_values_for(:number, "201504")
      end
    end
  end

  describe ".roll_up" do
    let(:user) { create(:user) }
    let(:user_2) { create(:user) }

    it "consolidates days from two months ago" do
      create(:day, {
        user: user,
        date: 3.months.ago.end_of_month.to_date,
        client_hours: "0.1".to_d,
        internal_hours: "0.2".to_d
      })
      create(:day, {
        user: user,
        date: 2.months.ago.beginning_of_month.to_date,
        client_hours: "0.4".to_d,
        internal_hours: "0.8".to_d
      })
      create(:day, {
        user: user,
        date: 2.months.ago.end_of_month.to_date,
        client_hours: "1.6".to_d,
        internal_hours: "3.2".to_d
      })
      create(:day, {
        user: user,
        date: 1.month.ago.beginning_of_month.to_date,
        client_hours: "6.4".to_d,
        internal_hours: "12.8".to_d
      })

      expect {
        Month.roll_up(user: user)
      }.to change {
        Month.count
      }.from(0).to(1)

      month = Month.last
      expect(month.user).to eq(user)
      expect(month.number).to eq(2.months.ago.strftime("%Y%m"))
      expect(month.client_hours).to eq("2.0".to_d)
      expect(month.internal_hours).to eq("4.0".to_d)

      expect(Day.count).to eq(2)
    end

    it "consolidates days for a given month" do
      create(:day, {
        user: user,
        date: 2.months.ago.end_of_month.to_date,
        client_hours: "0.1".to_d,
        internal_hours: "0.2".to_d
      })
      create(:day, {
        user: user,
        date: 1.month.ago.beginning_of_month.to_date,
        client_hours: "0.4".to_d,
        internal_hours: "0.8".to_d
      })
      create(:day, {
        user: user,
        date: 1.month.ago.end_of_month.to_date,
        client_hours: "1.6".to_d,
        internal_hours: "3.2".to_d
      })
      create(:day, {
        user: user,
        date: Time.current.beginning_of_month.to_date,
        client_hours: "6.4".to_d,
        internal_hours: "12.8".to_d
      })

      number = 1.month.ago.strftime("%Y%m")

      expect {
        Month.roll_up(user: user, number: number)
      }.to change {
        Month.count
      }.from(0).to(1)

      month = Month.last
      expect(month.user).to eq(user)
      expect(month.number).to eq(number)
      expect(month.client_hours).to eq("2.0".to_d)
      expect(month.internal_hours).to eq("4.0".to_d)

      expect(Day.count).to eq(2)
    end

    it "does nothing if the month already exists" do
      create(:day, user: user, date: 2.months.ago.to_date)
      create(:month, user: user, number: 2.months.ago.strftime("%Y%m"))

      expect {
        Month.roll_up(user: user)
      }.not_to change {
        Month.count
      }

      expect(Day.count).to eq(1)
    end

    it "does nothing if there are no days for the given month" do
      expect {
        Month.roll_up(user: user)
      }.not_to change {
        Month.count
      }
    end

    it "rolls up days for all users" do
      create(:day, {
        user: user,
        date: 2.months.ago.to_date,
        client_hours: "0.1".to_d,
        internal_hours: "0.2".to_d
      })
      create(:day, {
        user: user_2,
        date: 2.months.ago.to_date,
        client_hours: "0.4".to_d,
        internal_hours: "0.8".to_d
      })

      expect {
        Month.roll_up
      }.to change {
        Month.count
      }.from(0).to(2)

      month_1 = user.months.last
      expect(month_1.client_hours).to eq("0.1".to_d)
      expect(month_1.internal_hours).to eq("0.2".to_d)

      month_2 = user_2.months.last
      expect(month_2.client_hours).to eq("0.4".to_d)
      expect(month_2.internal_hours).to eq("0.8".to_d)

      expect(Day.count).to eq(0)
    end

    it "rolls up days for all users for the given month" do
      create(:day, {
        user: user,
        date: 1.month.ago.to_date,
        client_hours: "0.1".to_d,
        internal_hours: "0.2".to_d
      })
      create(:day, {
        user: user_2,
        date: 1.month.ago.to_date,
        client_hours: "0.4".to_d,
        internal_hours: "0.8".to_d
      })

      number = 1.month.ago.strftime("%Y%m")

      expect {
        Month.roll_up(number: number)
      }.to change {
        Month.count
      }.from(0).to(2)

      month_1 = user.months.last
      expect(month_1.number).to eq(number)
      expect(month_1.client_hours).to eq("0.1".to_d)
      expect(month_1.internal_hours).to eq("0.2".to_d)

      month_2 = user_2.months.last
      expect(month_2.number).to eq(number)
      expect(month_2.client_hours).to eq("0.4".to_d)
      expect(month_2.internal_hours).to eq("0.8".to_d)

      expect(Day.count).to eq(0)
    end
  end
end
