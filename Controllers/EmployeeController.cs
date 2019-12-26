using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class EmployeeController : Controller
    {
        // GET: Employee
        public ActionResult Edit(int id)
        {
            EmployeeMain employeeMain = new EmployeeMain();
            return View(employeeMain.GetEmployee(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,firstname,lastname,phone,salary,storeid,hiretime")] Employee employee)
        {
            if (ModelState.IsValid)
            {
                string cmd = "Update Employee set first_name = @firstname, last_name = @lastname, phone = @phone, salary = @salary," +
                    " hire_date = @hiretime WHERE employeeid = @Id";
                EmployeeMain EmployeeMain = new EmployeeMain();
                if (EmployeeMain.UpdateEmployee(cmd, employee) == true)
                {
                    return RedirectToAction("Employee", "Admin");
                }
                else
                {
                    Response.Write("Failed!");
                }
            }
            return View();
        }
        public ActionResult Create()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(Employee employee)
        {
            if (ModelState.IsValid)
            {
                string cmd = "INSERT INTO Employee (Storeid,first_name, last_name, phone, salary,hire_date,Managerid)"
                    + " VALUES (" + employee.StoreId + ", '" + employee.FirstName + "', '"+employee.LastName + "', '"+employee.Phone + "'," +
                    employee.Salary + ", '" + (employee.HireTime).ToString("yyyy-MM-dd") +"', " + employee.ManagerId + ")";
                DataContext dataContext = new DataContext();
                if (dataContext.ExecuteQuery(cmd) == true)
                {
                    return RedirectToAction("Employee", "Admin");
                }

            }
            return RedirectToAction("Index", "Error");
        }
        public ActionResult Delete(int id)
        {
            EmployeeMain employeeMain = new EmployeeMain();
            if (employeeMain.DeleteEmployee(id) == true)
            {
                return RedirectToAction("Employee", "Admin");
            }
            else
            {
                return View();
            }
        }
    }
}