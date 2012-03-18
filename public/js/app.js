var isbnRegex = /^(\w{13}|\w{10})$/;
var userRegex = /^\d{5}$/;
var maxWaitTime = 5;
var waitTime = 0;

var Reservation = Backbone.Model.extend({
  initialize: function() {
    this._bookDom = $("book");
    this._userDom = $("user");
    this._confirmationDom = $("confirmation");
    this._waitNotification = $("wait");
    this.reset();
  },
  defaults: {
    user: "",
    isbn: ""
  },
  _bindUserInputs: function() {
    $$("input.barcode").each(function(element) {
      element.purge();
      element.value = "";
      element.observe("keypress", function(e){
        element = e.element();
        if (e.keyCode == 13) this.set(element.readAttribute("data-input-type"), element.value);
      }.bind(this));
    }, this);
  },
  _highlight: function(section) {
    section.appear({afterFinish: function(){
      this.focus(section);
    }.bind(this)});
    section.highlight({startcolor: '#ffff99', endcolor: '#EEEEEE', queue: 'end'});
  },
  _updateWaitTime: function(value) {
    this._waitNotification.update(value);
  },
  focus: function(section) {
    section.select("input.barcode").all(function(element) {
      element.value = "";
      element.focus();
    });
  },
  validate: function(attrs) {
    if (attrs.isbn && !isbnRegex.test(attrs.isbn))
      return "Invalid ISBN";
    else if (attrs.user && !userRegex.test(attrs.user))
      return "Invalid EmployeeID";
  },
  getBookDetails: function() {
    this._confirmationDom.fade({afterFinish: function() {
      this._updateWaitTime(maxWaitTime);
    }.bind(this)});
    this._highlight(this._bookDom);
  },
  getUserDetails: function() {
    this._bookDom.fade();
    this._highlight(this._userDom);
  },
  showConfirmation: function() {
    this._userDom.fade();
    this._highlight(this._confirmationDom);
    this.timerId = setInterval(function() {
      this._updateWaitTime(maxWaitTime - waitTime);
      waitTime += 1;
      if (waitTime >= maxWaitTime) {
        waitTime = 0;
        clearInterval(this.timerId);
        this.trigger("confirmed");
      }
    }.bind(this), 1000);
  },
  reset: function() {
    this._bindUserInputs();
    this.getBookDetails();
  }
});

var reservation;

function newReservation() {
  reservation = new Reservation();
  reservation.on("error", function(model, error){ smoke.signal(error); });
  reservation.on("change:isbn", function(model, isbn) { reservation.getUserDetails(); });
  reservation.on("change:user", function(model, isbn) { reservation.showConfirmation(); });
  reservation.on("confirmed", newReservation);
}

document.observe("dom:loaded", function() { newReservation(); })