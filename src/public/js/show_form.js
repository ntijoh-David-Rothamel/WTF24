document.addEventListener("DOMContentLoaded", function(){
    // Get all elements with the class "toggleButton"
    var buttons = document.querySelectorAll(".toggleButton");
    console.log('works like a charm');
// Loop through each button
    buttons.forEach(function(button) {
        console.log("works");
        // Add click event listener to each button
        button.addEventListener("click", function() {
            // Get the target element id from the data-target attribute
            var targetId = button.getAttribute("data-target");
            var element = document.getElementById(targetId);

            console.log('in loop');
            // Toggle the display of the target element
            if (element.style.display === "none") {
                element.style.display = "block";
            } else {
                element.style.display = "none";
            }
        });
    });
});
