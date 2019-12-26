using SumoTech.Entity;
using SumoTech.Models;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class ProductController : Controller
    {
        DataContext dataContext = new DataContext();
        public Item getItem(int id)
        {
            Item item = new Item();
            
            dataContext.OpenConnection();

            string cmdString = "SELECT * FROM Item where itemid = " + id;
            SqlDataReader nwReader = dataContext.Execute(cmdString);
            while (nwReader.Read())
            {
                item.Id = (int)nwReader["itemid"];
                item.Brand = (string)nwReader["brand"];
                item.Name = (string)nwReader["name_"];
                item.Price = (double)nwReader["price"];
                item.Production_year = (int)nwReader["production_year"];
                item.Description = (string)nwReader["item_description"];
                item.Type = (string)nwReader["item_type"];
            }
            dataContext.CloseConnection();
            return item;
        }
        // GET: Product
        public ActionResult Detail(int id)
        {
            return View(getItem(id));
        }
        public ActionResult Edit(int id)
        {
            ItemMain itemMain = new ItemMain();
            return View(itemMain.GetItem(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,brand,name,price,production_year, description, type")] Item item)
        {
            if (ModelState.IsValid)
            {
                string cmd = "UPDATE Item SET brand = @brand, name_ = @name, price = @price, production_year = @production_year, item_description = @description , item_type = @type WHERE itemid = @Id";
                ItemMain itemMain = new ItemMain();
                if (itemMain.UpdateItem(cmd, item) == true)
                {
                    return RedirectToAction("Item", "Admin");
                }
                else
                {
                    return RedirectToAction("Index","Error");
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
        public ActionResult Create([Bind(Include = "brand,name,price,production_year, description, type")] Item item)
        {
            if (ModelState.IsValid)
            {
                string cmd = "insert into Item (brand,name_,price,production_year,item_description, item_type)"
                    + " values (@brand,@name,@price,@production_year, @description, @type)";
                ItemMain itemMain = new ItemMain();
                if (itemMain.CreateItem(cmd, item) == true)
                {
                    return RedirectToAction("Item", "Admin");
                }
                else
                {
                    return RedirectToAction("Index","Error");
                }

            }
            return View();
        }
        public ActionResult CreateRam()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateRam(RAM ram)
        {
            SqlCommand sql = new SqlCommand("InsertRAM",dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", ram.Brand);
            sql.Parameters.AddWithValue("@name", ram.Name);
            sql.Parameters.AddWithValue("@price", ram.Price);
            sql.Parameters.AddWithValue("@item_description", ram.Description);
            sql.Parameters.AddWithValue("@production_year", ram.Production_year);
            sql.Parameters.AddWithValue("@supplierid", ram.Supplierid);
            sql.Parameters.AddWithValue("@memory", ram.Memory);
            sql.Parameters.AddWithValue("@speed", ram.Speed);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            
            return RedirectToAction("Item","Admin");
        }
        public ActionResult CreateCPU()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateCPU(CPU cpu)
        {
            SqlCommand sql = new SqlCommand("InsertCpu", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", cpu.Brand);
            sql.Parameters.AddWithValue("@name", cpu.Name);
            sql.Parameters.AddWithValue("@price", cpu.Price);
            sql.Parameters.AddWithValue("@item_description", cpu.Description);
            sql.Parameters.AddWithValue("@production_year", cpu.Production_year);
            sql.Parameters.AddWithValue("@supplierid", cpu.Supplierid);
            sql.Parameters.AddWithValue("@cpuModel", cpu.Model);
            sql.Parameters.AddWithValue("@cpuCoreCount", cpu.CoreCount);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult CreateGPU()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateGPU(GPU gpu)
        {
            SqlCommand sql = new SqlCommand("InsertGpu", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", gpu.Brand);
            sql.Parameters.AddWithValue("@name", gpu.Name);
            sql.Parameters.AddWithValue("@price", gpu.Price);
            sql.Parameters.AddWithValue("@item_description", gpu.Description);
            sql.Parameters.AddWithValue("@production_year", gpu.Production_year);
            sql.Parameters.AddWithValue("@supplierid", gpu.Supplierid);
            sql.Parameters.AddWithValue("@chipset", gpu.Chipset);
            sql.Parameters.AddWithValue("@memory", gpu.Memory);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult CreateHarddisk()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateHarddisk(Harddisk harddisk)
        {
            SqlCommand sql = new SqlCommand("InsertHarddisk", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", harddisk.Brand);
            sql.Parameters.AddWithValue("@name", harddisk.Name);
            sql.Parameters.AddWithValue("@price", harddisk.Price);
            sql.Parameters.AddWithValue("@item_description", harddisk.Description);
            sql.Parameters.AddWithValue("@production_year", harddisk.Production_year);
            sql.Parameters.AddWithValue("@supplierid", harddisk.Supplierid);
            sql.Parameters.AddWithValue("@memory", harddisk.Memory);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult CreateElectronic()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateElectronic(BasicElectronic basicElectronic)
        {
            SqlCommand sql = new SqlCommand("InsertHarddisk", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", basicElectronic.Brand);
            sql.Parameters.AddWithValue("@name", basicElectronic.Name);
            sql.Parameters.AddWithValue("@price", basicElectronic.Price);
            sql.Parameters.AddWithValue("@item_description", basicElectronic.Description);
            sql.Parameters.AddWithValue("@production_year", basicElectronic.Production_year);
            sql.Parameters.AddWithValue("@supplierid", basicElectronic.Supplierid);
            sql.Parameters.AddWithValue("@electronicType", basicElectronic.ElectronicType);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult CreateTelevision()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateTelevision(Television television)
        {
            SqlCommand sql = new SqlCommand("InsertTelevision", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", television.Brand);
            sql.Parameters.AddWithValue("@name", television.Name);
            sql.Parameters.AddWithValue("@price", television.Price);
            sql.Parameters.AddWithValue("@item_description", television.Description);
            sql.Parameters.AddWithValue("@production_year", television.Production_year);
            sql.Parameters.AddWithValue("@supplierid", television.Supplierid);
            sql.Parameters.AddWithValue("@screensize", television.ScreenSize);
            sql.Parameters.AddWithValue("@screenResolution", television.ScreenResolution);
            if(television.IsSmart == true)
                sql.Parameters.AddWithValue("@isSmart", 'y');
            else
                sql.Parameters.AddWithValue("@isSmart", 'n');
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult CreateHousehold()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CreateHousehold(HouseHold houseHold)
        {
            SqlCommand sql = new SqlCommand("InsertHousehold", dataContext.GetConnection());
            sql.CommandType = System.Data.CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@brand", houseHold.Brand);
            sql.Parameters.AddWithValue("@name", houseHold.Name);
            sql.Parameters.AddWithValue("@price", houseHold.Price);
            sql.Parameters.AddWithValue("@item_description", houseHold.Description);
            sql.Parameters.AddWithValue("@production_year", houseHold.Production_year);
            sql.Parameters.AddWithValue("@factoryid", houseHold.Factoryid);
            sql.Parameters.AddWithValue("@applienceType", houseHold.ApplienceType);
            sql.Parameters.AddWithValue("@applienceProductivity", houseHold.ApplienceProductivity);
            dataContext.OpenConnection();
            try
            {
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            return RedirectToAction("Item", "Admin");
        }
        public ActionResult Delete(int id)
        {
            ItemMain itemMain = new ItemMain();
            if (itemMain.DeleteItem(id) == true)
            {
                return RedirectToAction("Item", "Admin");
            }
            else
            {
                return RedirectToAction("Index","Error");
            }
        }
    }
}