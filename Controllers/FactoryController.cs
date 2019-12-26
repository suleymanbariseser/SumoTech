using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class FactoryController : Controller
    {
        // GET: Factory
        public ActionResult Edit(int id)
        {
            FactoryMain factoryMain = new FactoryMain();
            ViewBag.Items = factoryMain.GetFactoryItems(id);
            return View(factoryMain.GetFactory(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,country,city,address, capacity ")] Factory factory)
        {
            if (ModelState.IsValid)
            {
                string cmd = "UPDATE Factory SET country = @country, city = @city, address_ = @address, productionCapacity = @capacity WHERE factoryid = @Id";
                FactoryMain factoryMain = new FactoryMain();
                Response.Write(factory.Id +" " + factory.Country + " "+ factory.City);
                if (factoryMain.UpdateFactory(cmd, factory) == true)
                {
                    return RedirectToAction("Factory", "Admin");
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
        public ActionResult Create([Bind(Include = "country,city,address, capacity ")] Factory factory)
        {
            if (ModelState.IsValid)
            {
                string cmd = "INSERT INTO Factory (country, city, address_ , productionCapacity)"
                    + " VALUES (@country, @city, @address, @capacity)";
                FactoryMain factoryMain = new FactoryMain();
                if (factoryMain.CreateFactory(cmd, factory) == true)
                {
                    return RedirectToAction("Factory", "Admin");
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
            FactoryMain factoryMain = new FactoryMain();
            if (factoryMain.DeleteFactory(id) == true)
            {
                return RedirectToAction("Factory", "Admin");
            }
            else
            {
                return View();
            }
        }
    }
}