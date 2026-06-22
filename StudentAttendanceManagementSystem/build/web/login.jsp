<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login</title>
        <link rel="stylesheet" href="login.css">
    </head>
    <body>

        <form class="card" name="login" id="login" method="POST" action="LoginServlet">

            <div class="card-header">
                <h2>SAMS PORTAL</h2>
                <h3>Student Attendance Monitoring System</h3>
            </div>

            <% if (request.getAttribute("error") != null) {%>
            <p style="color:red; text-align:center; font-weight:bold;"><%= request.getAttribute("error")%></p>
            <% }%>

            <div class="login-form-body">

                <div class="form-group">
                    <span class="group-label">SELECT ROLE</span>
                    <div class="role-container">
                        <label>
                            <input type="radio" name="role" value="Student" checked required> Student
                        </label>
                        <label>
                            <input type="radio" name="role" value="Lecturer"> Lecturer
                        </label>
                        <label>
                            <input type="radio" name="role" value="Admin"> Admin
                        </label>
                    </div>
                </div>

                <div class="form-group">
                    <span class="group-label" id="id-label">MATRIC NO</span>
                    <input type="text" name="userid" id="user-id-input" placeholder="matric no" required>
                </div>

                <div class="form-group">
                    <span class="group-label">PASSWORD</span>
                    <input type="password" name="user_password" placeholder="password" required>
                </div>

            </div>

            <input type="submit" value="LOGIN">

        </form>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const idLabel = document.getElementById("id-label");
                const idInput = document.getElementById("user-id-input");
                const roleRadios = document.querySelectorAll('input[name="role"]');

                function updateLabels() {
                    const selectedRole = document.querySelector('input[name="role"]:checked');
                    if (selectedRole) {
                        if (selectedRole.value === "Student") {
                            idLabel.textContent = "MATRIC NO";
                            idInput.placeholder = "matric no";
                        } else {
                            idLabel.textContent = "STAFF ID";
                            idInput.placeholder = "staff id";
                        }
                    }
                }

                roleRadios.forEach(radio => {
                    radio.addEventListener("change", updateLabels);
                });

                updateLabels(); // Initialize on page load
            });
        </script>
    </body>
</html>