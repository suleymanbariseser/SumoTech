using SumoTech.Entity;
using System;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class UserController : Controller
    {
        UserMain userMain = new UserMain();
        // GET: User
        public ActionResult İnfo()
        {
            return View();
        }
        public ActionResult Cart()
        {
            return View();
        }
        public ActionResult Register()
        {
            return View();
        }
        public ActionResult Edit(int id)
        {
            return View(userMain.GetCustomer(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,firstname,lastname,phone,email")] Customer customer)
        {
            if (ModelState.IsValid)
            {
                string cmd = "Update Customer set first_name = @firstname, last_name = @lastname, Phone = @phone, Email = @email WHERE customerid = @Id";
                
                if (userMain.UpdateCustomer(cmd ,customer) == true)
                {
                    return RedirectToAction("Customer", "Admin");
                }
                else
                {
                    return RedirectToAction("Index", "Error");
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
        public ActionResult Create([Bind(Include = "firstname,lastname,phone,email")] Customer customer)
        {
            if (ModelState.IsValid)
            {
                string cmd = "INSERT INTO Customer (first_name, last_name, phone, Email)"
                    + " VALUES (@firstname,@lastname,@phone,@email)";
                Response.Write(customer.FirstName + " " + customer.LastName);
                if (userMain.CreateCustomer(cmd, customer) == true)
                {
                    return RedirectToAction("Customer", "Admin");
                }
                else
                {
                    return RedirectToAction("Index", "Error");
                }

            }
            return View();
        }
        public ActionResult NewOrderLine(int userid,string address)
        {
            Response.Write(address);
            string cmd = "INSERT INTO OrderLine (customerid, destination_address)" +
                " Values (" + userid +", '" + address +"' )";
            if (userMain.ExecuteQuery(cmd) == true)
            {
                return RedirectToAction("Edit", new { id = userid});
            }
            else
            {
                Response.Write(address);
                return RedirectToAction("Index", "Error");
            }
        }
        public ActionResult NewAddress(int userid, string country,string city, string address)
        {
            Response.Write("sadasd");
            string cmd = "INSERT INTO CustomerAddress (customerid, country, city, address_)" +
                " VALUES (" + userid +", '" + country +"', '" + city +"', '" + address + "')";
            if(userMain.ExecuteQuery(cmd) == true)
            {
                return RedirectToAction("Edit", new { id = userid });
            }
            else
            {
                return RedirectToAction("Index", "Error");
            }
        }
        public ActionResult DeleteAddress(int Id, int addressid)
        {
            string cmd = "DELETE FROM CustomerAddress WHERE addressid = " + addressid;
            if(userMain.ExecuteQuery(cmd) == true)
            {
                return RedirectToAction("Edit", new { id = Id});
            }
            else
            {
                return RedirectToAction("Index", "Error");
            }
        }
        public ActionResult DeleteOrderLine(int Id)
        {
            string cmd = "DELETE FROM OrderLine WHERE orderlineid = " + Id;
            if (userMain.ExecuteQuery(cmd) == true)
                return RedirectToAction("Customer", "Admin");
            else
                return RedirectToAction("Store", "Admin");
        }
        public ActionResult Delete(int id)
        {
            UserMain userMain = new UserMain();
            if (userMain.DeleteCustomer(id) == true)
            {
                return RedirectToAction("Customer", "Admin");
            }
            else
            {
                Response.Write("Error!!");
                return RedirectToAction("Index", "Error");
            }
        }
    }
}