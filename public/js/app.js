var isbnRegex = /^(\w{13}|\w{10})$/;
var userRegex = /^\d{5}$/;

var Reservation = Backbone.Model.extend({
  initialize: function() {
    this._bookDom = $("book");
    this._userDom = $("user");
    this._confirmationDom = $("confirmation");
    this._bindUserInputs();
    this.focus(this._bookDom);
  },
  defaults: {
    user: "",
    isbn: ""
  },
  _bindUserInputs: function() {
    $$("input.barcode").each(function(element) {
      element.observe("keypress", function(e){
        element = e.element();
        if (e.keyCode == 13)
          this.set(element.readAttribute("data-input-type"), element.value);
      }.bind(this));
    }, this);
  },
  _highlight: function(section) {
    section.highlight({startcolor: '#ffff99', endcolor: '#EEEEEE', queue: 'end', afterFinish: function(){
      this.focus(section);
    }.bind(this)});
  },
  focus: function(section) {
    section.select("input").all(function(element) { element.focus(); });
  },
  validate: function(attrs) {
    if (attrs.isbn && !isbnRegex.test(attrs.isbn))
      return "Invalid ISBN";
    else if (attrs.user && !userRegex.test(attrs.user))
      return "Invalid EmployeeID";
  },
  getBookDetails: function() {
    this._confirmationDom.fade();
    this._bookDom.appear();
  },
  getUserDetails: function() {
    this._bookDom.fade();
    this._userDom.appear();
    this._highlight(this._userDom);
  },
  showConfirmation: function() {
    this._userDom.fade();
    this._confirmationDom.appear();
    this._highlight(this._confirmationDom);
  }
});

var reservation;

document.observe("dom:loaded", function() {
  reservation = new Reservation();
  reservation.on("error", function(model, error){
    smoke.signal(error);
  });
  reservation.on("change:isbn", function(model, isbn) {
    reservation.getUserDetails();
  });
  reservation.on("change:user", function(model, isbn) {
    reservation.showConfirmation();
  });
});