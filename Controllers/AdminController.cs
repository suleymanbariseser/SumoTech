using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data;
using System.Data.SqlClient;
using System.Data.Sql;
using System.Web.Configuration;

namespace SumoTech.Controllers
{

    public class AdminController : Controller
    {
        // GET: Admin
        public ActionResult Home()
        {
            return View();
        }
        public ActionResult Store()
        {
            return View();
        }
        public ActionResult Item()
        {
            return View();
        }
        public ActionResult Customer()
        {
            return View();
        }
        public ActionResult Factory()
        {
            return View();
        }
        public ActionResult Supplier()
        {
            return View();
        }
        public ActionResult Employee()
        {
            return View();
        }
    }
}