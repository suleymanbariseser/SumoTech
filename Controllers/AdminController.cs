using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using System.Data.SqlClient;
using System.Data.Sql;
using System.Web.Configuration;
using SumoTech.Entity;

namespace SumoTech.Controllers
{

    public class AdminController : Controller
    {
        // GET: Admin
        public ActionResult Home()
        {
            DataContext dataContext = new DataContext();
            string cmd = "Select * from most_expensive_order";
            dataContext.OpenConnection();
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                ViewBag.Id = (int)sqlDataReader["ıd"];
                ViewBag.price = (double)sqlDataReader["order_price"];
                ViewBag.firstname = (string)sqlDataReader["first_name"];
                ViewBag.lastname = (string)sqlDataReader["last_name"];
                ViewBag.year = (int)sqlDataReader["y"];
                ViewBag.month = (int)sqlDataReader["m"];
                ViewBag.day = (int)sqlDataReader["d"];
            }
            dataContext.CloseConnection();
            string cmd1 = "select * from old_stuff";
            dataContext.OpenConnection();
            SqlDataReader sqlDataReader1 = dataContext.Execute(cmd1);
            while (sqlDataReader1.Read())
            {
                ViewBag.production_year = (int)sqlDataReader1["production_year"];
                ViewBag.itemid = (int)sqlDataReader1["itemid"];
                ViewBag.type = (string)sqlDataReader1["item_type"];
                ViewBag.brand = (string)sqlDataReader1["brand"];
                ViewBag.name = (string)sqlDataReader1["name_"];
                ViewBag.storeid = (int)sqlDataReader1["storeid"];
            }
            dataContext.CloseConnection();
            return View();
        }
        public ActionResult Store()
        {
            StoreMain storeMain = new StoreMain();
            return View(storeMain.GetAllStores().ToList());
        }
        public ActionResult Item()
        {
            ItemMain itemMain = new ItemMain();
            return View(itemMain.GetAllItems(0).ToList());
        }
        public ActionResult Customer()
        {
            UserMain userMain = new UserMain();
            return View(userMain.GetAllCustomers().ToList());
        }
        public ActionResult Factory()
        {
            FactoryMain factoryMain = new FactoryMain();
            return View(factoryMain.GetAllFactories().ToList());
        }
        public ActionResult Supplier()
        {
            SupplierMain supplierMain = new SupplierMain();
            return View(supplierMain.GetAllSuppliers().ToList());
        }
        public ActionResult Employee()
        {
            EmployeeMain employeeMain = new EmployeeMain();
            return View(employeeMain.GetAllEmployees().ToList());
        }
    }
}