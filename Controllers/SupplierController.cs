using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class SupplierController : Controller
    {
        // GET: Supplier
        public ActionResult Edit(int id)
        {
            SupplierMain supplierMain = new SupplierMain();
            ViewBag.Items = supplierMain.GetSupplierItems(id);
            return View(supplierMain.GetSupplier(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,name,country,city,address,phone")] Supplier supplier)
        {
            if (ModelState.IsValid)
            {
                string cmd = "UPDATE Supplier SET name_ = @name, country = @country, city = @city, address_ = @address, phone = @phone WHERE supplierid = @Id";
                SupplierMain SupplierMain = new SupplierMain();
                if (SupplierMain.UpdateSupplier(cmd, supplier) == true)
                {
                    return RedirectToAction("Supplier", "Admin");
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
        public ActionResult Create([Bind(Include = "name,country,city,address,phone")] Supplier supplier)
        {
            if (ModelState.IsValid)
            {
                string cmd = "INSERT INTO Supplier (name_, country,city, address_, phone)"
                    + " VALUES (@name,@country,@city,@address,@phone)";
                SupplierMain SupplierMain = new SupplierMain();
                if (SupplierMain.CreateSupplier(cmd, supplier) == true)
                {
                    return RedirectToAction("Supplier", "Admin");
                }
                else
                {
                    Response.Write("Failed!");
                }

            }
            return View();
        }
        public ActionResult Delete(int id)
        {
            SupplierMain supplierMain = new SupplierMain();
            if (supplierMain.DeleteSupplier(id) == true)
            {
                return RedirectToAction("Supplier", "Admin");
            }
            else
            {
                return View();
            }
        }
    }
}