using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class HomeController : Controller
    {

        public List<Item> GetItems(int category)
        {
            List<Item> items = new List<Item>();
            DataContext db = new DataContext();
            db.OpenConnection();
            String command = "";

            if (category == 1)
            {
                command = " WHERE item_type = 'Television'";
            }
            else if (category == 2)
            {
                command = " WHERE item_type = 'Computer Part'";
            }

            else if (category == 3)
            {
                command = " WHERE item_type = 'Basic Electronic'";
            }

            else if (category == 4)
            {
                command = " WHERE item_type = 'HouseHold Applience'";
            }
            else
            {
                command = "";
            }

            string cmdString = "SELECT * FROM Item" + command;
            SqlDataReader nwReader = db.Execute(cmdString);
            while (nwReader.Read())
            {
                Item item = new Item();
                item.Id = (int)nwReader["itemid"];
                item.Brand = (string)nwReader["brand"];
                item.Name = (string)nwReader["name_"];
                item.Price = (double)nwReader["price"];
                item.Production_year = (int)nwReader["production_year"];
                item.Description = (string)nwReader["item_description"];
                item.Type = (string)nwReader["item_type"];
                if (item.Type == "Television")
                {
                    item.Image = "img1.jpg";
                }
                else if (item.Type == "Computer Part")
                    item.Image = "img2.jpg";

                else if (item.Type == "Basic Electronic")
                    item.Image = "img3.jpg";
                else if (item.Type == "HouseHold Applience")
                    item.Image = "img4.jpg";
                else
                    item.Image = "nophoto.png";
                items.Add(item);
            }
            nwReader.Close();
            db.CloseConnection();
            return items;
        }
        // GET: Home
        public ActionResult Index()
        {
            return View(GetItems(0).ToList());
        }
        public ActionResult Television()
        {
            return View(GetItems(1).ToList());
        }
        public ActionResult Computer()
        {
            return View(GetItems(2).ToList());
        }
        public ActionResult Electronic()
        {
            return View(GetItems(3).ToList());
        }
        public ActionResult HouseHold()
        {
            return View(GetItems(4).ToList());
        }
    }
}