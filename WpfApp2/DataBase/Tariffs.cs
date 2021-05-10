using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WpfApp2.DataBase
{
    public class Tariffs
    {
        public string Name { get; set; }
        public string Price { get; set; }

        public Tariffs(string name, string price)
        {
            Name = name;
            Price = price;
        }
    }
}
