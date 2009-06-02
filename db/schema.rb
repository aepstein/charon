# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090602153313) do

  create_table "administrative_expenses", :force => true do |t|
    t.integer  "copies"
    t.decimal  "copies_expense"
    t.decimal  "repairs_restocking"
    t.integer  "mailbox_wsh"
    t.decimal  "total_request"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total"
  end

end
