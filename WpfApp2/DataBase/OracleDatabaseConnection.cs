using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WpfApp2.DataBase
{
    public static class OracleDatabaseConnection
    {
        public static string adminConn = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)" +
                                         "(HOST=192.168.56.103)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=mobile_operator.be.by)))" +
                                         ";User Id=Administrator;Password=1357Gfgfdbnz76;";
        public static string employeeConn = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)" +
                                         "(HOST=192.168.56.103)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=mobile_operator.be.by)))" +
                                         ";User Id=employee;Password=emppass;";
        public static string clientConn = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)" +
                                            "(HOST=192.168.56.103)(PORT=1521)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=mobile_operator.be.by)))" +
                                            ";User Id=client;Password=clipass;";
    }
}
