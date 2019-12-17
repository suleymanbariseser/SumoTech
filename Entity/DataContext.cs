using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class DataContext : DbContext
    {
        public DataContext(): base("dataConnection")
        {

        }
    }
}