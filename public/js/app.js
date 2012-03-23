var isbnRegex = /^(\w{13}|\w{10})$/;
var userRegex = /^\d{5}$/;
var maxWaitTime = 5;
var waitTime = 0;

var Reservation = Backbone.Model.extend({
  defaults: {
    user: "",
    isbn: ""
  },
  validate: function(attrs) {
    if (attrs.isbn && !isbnRegex.test(attrs.isbn))
      return "Invalid ISBN";
    else if (attrs.user && !userRegex.test(attrs.user))
      return "Invalid EmployeeID";
  },
  read: function() {
    this.trigger("read");
  }
});

var ReservationView = Backbone.View.extend({
  events: {
    "keypress input.barcode": "save"
  },
  _highlight: function() {
    //section.highlight({startcolor: '#ffff99', endcolor: '#EEEEEE', queue: 'end'});
  },
  focus: function() {
    barcodeInput = $(this.el).find("input.barcode");
    barcodeInput.val("");
    barcodeInput.focus();
  },
  save: function(event) {
    element = event.target;
    if (event.keyCode == 13 && element.value != "") this.model.set($(element).attr("data-input-type"), element.value);
  },
  hide: function() {
    $(this.el).fadeOut();
  },
  show: function() {
    $(this.el).fadeIn();
    this.focus();
  }
})

var BookView = ReservationView.extend({
  initialize: function(options) {
    this.setElement($("#book"));
    this.model.on("read", $.proxy(this.show, this));
    this.model.on("change:isbn", $.proxy(this.getBookInfo, this));
  },
  getBookInfo: function() {
    bookXhr = $.getJSON("books/"+this.model.get("isbn"));
    bookXhr.success($.proxy(this.updateBookInfo, this));
    //this.hide();
  },
  updateBookInfo: function(data) {
    console.log(data.title);
    console.log($(this.el).find(".book-name"));
    $(this.el).find(".book-name").html(data.title);
  }
});

var UserView = ReservationView.extend({
  initialize: function(options) {
    this.setElement($("#user"));
    this.model.on("change:user", $.proxy(this.hide, this));
    this.model.on("change:isbn", $.proxy(this.show, this));
  }
})

var ConfirmationView = ReservationView.extend({
  initialize: function(options) {
    this.setElement($("#confirmation"));
    this.model.on("change:user", $.proxy(this.startTimer, this));
    this.model.on("read", $.proxy(this.hide, this));
    this._updateWaitTime(maxWaitTime);
  },
  _updateWaitTime: function(value) {
    $(this.el).find("#wait").html(value)
  },
  _updateTime: function() {
    waitTime += 1;
    this._updateWaitTime(maxWaitTime - waitTime);
    if (waitTime >= maxWaitTime) {
      waitTime = 0;
      clearInterval(this.timerId);
      this.model.save();
      this._updateWaitTime(maxWaitTime);
    }
  },
  startTimer: function() {
    this.show();
    this.timerId = setInterval($.proxy(this._updateTime, this), 1000);
  }
})

var reservation;
var bookView;
var userView;
var confirmationView;

function newReservation() {
  reservation = new Reservation();
  bookView = new BookView({model: reservation});
  userView = new UserView({model: reservation});
  confirmationView = new ConfirmationView({model: reservation});
  reservation.read();
  reservation.on("error", function(model, error){ smoke.signal(error); });
};

function saveReservation() {
}

function destroyReservation (argument) {
  bookView.undelegateEvents();
  userView.undelegateEvents();
  confirmationView.undelegateEvents();
  reservation = null;
  bookView = null;
  confirmationView = null;
};

$(function() { newReservation(); });

Backbone.sync = function(method, model) {
  saveReservation(model);
  destroyReservation();
  newReservation();
};