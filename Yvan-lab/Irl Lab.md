**Logical topology**

                                Internet
                                   |(.1)
                                   |
                             [192.0.2.0/30]
                                   |
                                   |(.2)
                                 RTR1-1 (Router)
                                   |(.1)
                                   |
                              [10.0.0.0/30]
                                   |
                                   |(.2)
                                 MLS1-1 (Layer 3 switch)
                     ---------------------------------
                    |                                 |
        [Trunk: VLANs 10, 11, 12, 99]       [Trunk: VLANs 10, 11, 12, 99]
                    |                                 |
             AS1-1(Access Switch)           AS2-1(Access Switch)
                    |                                   |
                VLAN 10, 11                         VLAN 10, 12

Legend:
- RTR1-1: Router with NAT and OSPF enabled.
- MLS1-1: Core switch with routing for VLANs.
- AS1-1 & AS2-1: Access switches handling VLAN-specific PCs.
- VLANs:
    - VLAN 10 (Orange): 10.1.10.0/24
    - VLAN 11 (Green): 10.1.11.0/24
    - VLAN 12 (Blue): 10.1.12.0/24
    - VLAN 99 (Management): 10.1.99.0/24
- NAT enabled between 10.x.x.x networks and the Internet.
- OSPF configured for dynamic routing across the topology.


**RTR1-1 configurations**

# GLOBAL CONFIGURATION
# Set the hostname of the router to "RT1-1"
RT1-1(config)# hostname RT1-1

# CONSOLE LINE CONFIGURATION
# Configure console access with a password and require login
RT1-1(config)# line console 0
RT1-1(config-line)# password cisco
RT1-1(config-line)# login
RT1-1(config-line)# exit

# GLOBAL CONFIGURATION
# Enable SSH version 2 for secure remote access
RT1-1(config)# ip ssh version 2

# VTY LINE CONFIGURATION
# Configure VTY lines to use local authentication and allow only SSH connections
RT1-1(config)# line vty 0 15
RT1-1(config-line)# login local
RT1-1(config-line)# transport input ssh
RT1-1(config-line)# exit

# INTERFACE CONFIGURATION FOR g0/0 (First Interface)
# Configure the IP address and bring up the interface
RT1-1(config)# interface g0/0
RT1-1(config-if)# ip address 10.0.0.1 255.255.255.0
RT1-1(config-if)# no shutdown

# COMMENT: NAT CONFIGURATION
# Set up IP addresses and NAT configuration for inside and outside interfaces

# INTERFACE CONFIGURATION FOR g0/0
RT1-1(config)# interface g0/0
RT1-1(config-if)# no shutdown
RT1-1(config-if)# ip address 192.0.2.2 255.255.255.252

# INTERFACE CONFIGURATION FOR g0/1
RT1-1(config)# interface g0/1
RT1-1(config-if)# no shutdown
RT1-1(config-if)# ip address 10.0.0.1 255.255.255.252

# INTERFACE CONFIGURATION FOR Loopback1
# Configure the Loopback1 interface with an IP address and enable it
RTR1-1(config)# interface lo1
RTR1-1(config-if)# no shutdown
RTR1-1(config-if)# ip address 172.16.1.1 255.255.255.0

**RTR1-1 configurations**

# ACCESS LIST CONFIGURATION
# Define a standard access list for NAT
RTR1-1(config)# ip access-list standard NAT
RTR1-1(config-std-nacl)# permit 10.0.0.0 0.0.0.3
RTR1-1(config-std-nacl)# permit 10.1.0.0 0.0.0.3
RTR1-1(config-std-nacl)# permit 10.1.10.0 0.0.0.255
RTR1-1(config-std-nacl)# permit 10.1.11.0 0.0.0.255
RTR1-1(config-std-nacl)# permit 10.1.12.0 0.0.0.255
RTR1-1(config-std-nacl)# permit 10.1.99.0 0.0.0.255
RTR1-1(config-std-nacl)# exit

# NAT CONFIGURATION
# Configure NAT settings on the interfaces
RTR1-1(config)# interface g0/0
RTR1-1(config-if)# ip nat outside
RTR1-1(config-if)# exit
RTR1-1(config)# interface g0/1
RTR1-1(config-if)# ip nat inside
RTR1-1(config-if)# exit

# Enable NAT overload using the access list
RTR1-1(config)# ip nat inside source list NAT interface g0/0 overload

# DEFAULT ROUTE CONFIGURATION
# Configure a default route through interface g0/0
RTR1-1(config)# ip route 0.0.0.0 0.0.0.0 g0/0

# OSPF CONFIGURATION
# Configure OSPF process ID 10
RTR1-1(config)# router ospf 10
RTR1-1(config-router)# router-id 1.1.1.1
RTR1-1(config-router)# auto-cost reference-bandwidth 1000
RTR1-1(config-router)# default-information originate
RTR1-1(config-router)# network 10.0.0.0 0.0.0.3 area 0
RTR1-1(config-router)# exit

# SAVE CONFIGURATION
# Save the configuration to NVRAM to ensure it persists across reboots
RT1-1# write memory

**MLS1-1 configurations**

# GLOBAL CONFIGURATION
# Set the hostname of the switch to "MLS1-1"
MLS1-1(config)# hostname MLS1-1

# ENABLE PASSWORD CONFIGURATION
# Set the enable secret password
MLS1-1(config)# enable secret cisco

# DOMAIN NAME CONFIGURATION
# Configure the domain name for SSH
MLS1-1(config)# ip domain-name BECODE.org

# USER ACCOUNT CONFIGURATION
# Create a local user account with username "admin" and password "cisco"
MLS1-1(config)# username admin secret cisco

# SSH CONFIGURATION
# Generate RSA keys for SSH and enable SSH version 2
MLS1-1(config)# crypto key generate rsa modulus 2048
MLS1-1(config)# ip ssh version 2

# VTY LINE CONFIGURATION
# Configure VTY lines to use local authentication and allow only SSH connections
MLS1-1(config)# line vty 0 15
MLS1-1(config-line)# login local
MLS1-1(config-line)# transport input ssh
MLS1-1(config-line)# exit

# ROUTING CONFIGURATION
# Enable IP routing
MLS1-1(config)# ip routing

# INTERFACE CONFIGURATION FOR f1/0/47
# Configure the interface with an IP address and enable it
MLS1-1(config)# interface f1/0/47
MLS1-1(config-if)# no switchport
MLS1-1(config-if)# no shutdown
MLS1-1(config-if)# ip address 10.0.0.2 255.255.255.252
MLS1-1(config-if)# exit

# VLAN CONFIGURATION
# Create and name VLANs

MLS1-1(config)# vlan 10
MLS1-1(config-vlan)# name ORANGE
MLS1-1(config-vlan)# exit

MLS1-1(config)# int vlan 10
MLS1-1(config-if)#ip add 10.1.10.1 255.255.255.0
MLS1-1(config-if)#no shutdown
MLS1-1(config-if)#exit

MLS1-1(config)# vlan 11
MLS1-1(config-vlan)# name GREEN
MLS1-1(config-vlan)# exit

MLS1-1(config)# int vlan 11
MLS1-1(config-if)#ip add 10.1.11.1 255.255.255.0
MLS1-1(config-if)#no shutdown
MLS1-1(config-if)#exit

MLS1-1(config)# vlan 12
MLS1-1(config-vlan)# name BLUE
MLS1-1(config-vlan)# exit

MLS1-1(config)# int vlan 12
MLS1-1(config-if)#ip add 10.1.12.1 255.255.255.0
MLS1-1(config-if)#no shut
MLS1-1(config-if)#exit

MLS1-1(config)# vlan 99
MLS1-1(config-vlan)# name MANAGEMENT
MLS1-1(config-vlan)# exit

MLS1-1(config)# int vlan 99
MLS1-1(config-if)#ip add 10.1.99.1 255.255.255.0
MLS1-1(config-if)#no shutdown
MLS1-1(config-if)#exit

# TRUNK PORT CONFIGURATION
# Configure trunk ports and allowed VLANs
MLS1-1(config)# interface f1/0/1
MLS1-1(config-if)# switchport mode trunk
MLS1-1(config-if)# switchport trunk allowed vlan 1,10,11,12,99
MLS1-1(config-if)# exit

MLS1-1(config)# interface f1/0/2
MLS1-1(config-if)# switchport mode trunk
MLS1-1(config-if)# switchport trunk allowed vlan 1,10,11,12,99
MLS1-1(config-if)# exit

# DHCP CONFIGURATION
# Exclude addresses for VLAN 10
MLS1-1(config)# ip dhcp excluded-address 10.1.10.1 10.1.10.10
MLS1-1(config)# ip dhcp excluded-address 10.1.10.254

# Create a DHCP pool for VLAN 10
MLS1-1(config)# ip dhcp pool ORANGE
MLS1-1(dhcp-config)# network 10.1.10.0 255.255.255.0
MLS1-1(dhcp-config)# default-router 10.1.10.1
MLS1-1(dhcp-config)# exit

# Exclude addresses for VLAN 11
MLS1-1(config)# ip dhcp excluded-address 10.1.11.1 10.1.11.10
MLS1-1(config)# ip dhcp excluded-address 10.1.11.254

# Create a DHCP pool for VLAN 11
MLS1-1(config)# ip dhcp pool GREEN
MLS1-1(dhcp-config)# network 10.1.11.0 255.255.255.0
MLS1-1(dhcp-config)# default-router 10.1.11.1
MLS1-1(dhcp-config)# exit

# Exclude addresses for VLAN 12
MLS1-1(config)# ip dhcp excluded-address 10.1.12.1 10.1.12.10
MLS1-1(config)# ip dhcp excluded-address 10.1.12.254

# Create a DHCP pool for VLAN 12
MLS1-1(config)# ip dhcp pool BLUE
MLS1-1(dhcp-config)# network 10.1.12.0 255.255.255.0
MLS1-1(dhcp-config)# default-router 10.1.12.1
MLS1-1(dhcp-config)# exit


# SPANNING TREE CONFIGURATION
# Enable Rapid PVST mode
# Set VLANs 1, 10, 11, and 12 as the primary root
MLS1-1(config)# spanning-tree mode rapid-pvst
MLS1-1(config)# spanning-tree vlan 1,10,11,12 root primary

# OSPF CONFIGURATION
# Configure OSPF process ID 10
MLS1-1(config)# router ospf 10
MLS1-1(config-router)# router-id 2.2.2.2
MLS1-1(config-router)# auto-cost reference-bandwidth 1000
MLS1-1(config-router)# network 10.0.0.0 0.0.0.3 area 0
MLS1-1(config-router)# network 10.1.0.0 0.0.0.3 area 0
MLS1-1(config-router)# network 10.1.11.0 0.0.0.255 area 0
MLS1-1(config-router)# network 10.1.12.0 0.0.0.255 area 0
MLS1-1(config-router)# network 10.1.99.0 0.0.0.255 area 0
MLS1-1(config-router)# passive-interface f1/0/1
MLS1-1(config-router)# passive-interface f1/0/2
MLS1-1(config-router)# exit

# VLAN CONFIGURATION
# Create and name the additional VLANs from the other rack
MLS1-1(config)# vlan 20
MLS1-1(config-vlan)# name PURPLE
MLS1-1(config-vlan)# exit

MLS1-1(config)# vlan 21
MLS1-1(config-vlan)# name RED
MLS1-1(config-vlan)# exit

MLS1-1(config)# vlan 22
MLS1-1(config-vlan)# name YELLOW
MLS1-1(config-vlan)# exit

# SAVE CONFIGURATION
# Save the configuration to NVRAM to ensure it persists across reboots
MLS1-1# write memory

# AS2-1 configurations

# CONSOLE LINE CONFIGURATION
# Configure console access with a password and enable synchronous logging
AS2-1(config)# line console 0
AS2-1(config-line)# logging synchronous
AS2-1(config-line)# password cisco
AS2-1(config-line)# login
AS2-1(config-line)# exit

# ENABLE PASSWORD CONFIGURATION
# Set the enable secret password
AS2-1(config)# enable secret cisco

# DOMAIN NAME CONFIGURATION
# Configure the domain name for SSH
AS2-1(config)# ip domain-name BECODE.org

# USER ACCOUNT CONFIGURATION
# Create a local user account with username "admin" and password "cisco"
AS2-1(config)# username admin secret cisco

# SSH CONFIGURATION
# Generate RSA keys for SSH and enable SSH version 2
AS2-1(config)# crypto key generate rsa
AS2-1(config)# ip ssh version 2

# VTY LINE CONFIGURATION
# Configure VTY lines to use local authentication and allow only SSH connections
AS2-1(config)# line vty 0 15
AS2-1(config-line)# login local
AS2-1(config-line)# transport input ssh
AS2-1(config-line)# exit

# SPANNING TREE CONFIGURATION
# Enable Rapid PVST mode
AS2-1(config)# spanning-tree mode rapid-pvst

# DEFAULT GATEWAY CONFIGURATION
# Configure the default gateway
AS2-1(config)# ip default-gateway 10.1.99.1

# VLAN INTERFACE CONFIGURATION
# Configure VLAN 99 interface with an IP address and enable it
AS2-1(config)# interface vlan 99
AS2-1(config-if)# ip address 10.1.99.3 255.255.255.0
AS2-1(config-if)# no shutdown
AS2-1(config-if)# exit

# VLAN CONFIGURATION
# Create and name VLANs
AS2-1(config)# vlan 10
AS2-1(config-vlan)# name ORANGE
AS2-1(config-vlan)# exit

AS2-1(config)# vlan 11
AS2-1(config-vlan)# name GREEN
AS2-1(config-vlan)# exit

AS2-1(config)# vlan 12
AS2-1(config-vlan)# name BLUE
AS2-1(config-vlan)# exit

AS2-1(config)# vlan 99
AS2-1(config-vlan)# name MANAGEMENT
AS2-1(config-vlan)# exit

# TRUNK PORT CONFIGURATION
# Configure the trunk port and allowed VLANs
AS2-1(config)# interface g2/0/23
AS2-1(config-if)# switchport mode trunk
AS2-1(config-if)# switchport trunk allowed vlan 1,10,11,12,99
AS2-1(config-if)# exit

# ACCESS PORT CONFIGURATION
# Configure access ports for VLAN 10
AS2-1(config)# interface range g2/0/1 - 10
AS2-1(config-if)# switchport mode access
AS2-1(config-if)# switchport access vlan 10
AS2-1(config-if)# exit

# Configure access ports for VLAN 12
AS2-1(config)# interface range g2/0/11 - 19
AS2-1(config-if)# switchport mode access
AS2-1(config-if)# switchport access vlan 12
AS2-1(config-if)# exit

# SAVE CONFIGURATION
# Save the configuration to NVRAM to ensure it persists across reboots
AS2-1# write memory

# AS1-1 configurations

# CONSOLE LINE CONFIGURATION
# Configure console access with a password and enable synchronous logging
AS1-1(config)# line console 0
AS1-1(config-line)# logging synchronous
AS1-1(config-line)# password cisco
AS1-1(config-line)# login
AS1-1(config-line)# exit

# ENABLE PASSWORD CONFIGURATION
# Set the enable secret password
AS1-1(config)# enable secret cisco

# DOMAIN NAME CONFIGURATION
# Configure the domain name for SSH
AS1-1(config)# ip domain-name BECODE.org

# USER ACCOUNT CONFIGURATION
# Create a local user account with username "admin" and password "cisco"
AS1-1(config)# username admin secret cisco

# SSH CONFIGURATION
# Generate RSA keys for SSH and enable SSH version 2
AS1-1(config)# crypto key generate rsa
AS1-1(config)# ip ssh version 2

# VTY LINE CONFIGURATION
# Configure VTY lines to use local authentication and allow only SSH connections
AS1-1(config)# line vty 0 15
AS1-1(config-line)# login local
AS1-1(config-line)# transport input ssh
AS1-1(config-line)# exit

# SPANNING TREE CONFIGURATION
# Enable Rapid PVST mode
AS1-1(config)# spanning-tree mode rapid-pvst

# DEFAULT GATEWAY CONFIGURATION
# Configure the default gateway
AS1-1(config)# ip default-gateway 10.1.99.1

# VLAN INTERFACE CONFIGURATION
# Configure VLAN 99 interface with an IP address and enable it
AS1-1(config)# interface vlan 99
AS1-1(config-if)# ip address 10.1.99.2 255.255.255.0
AS1-1(config-if)# no shutdown
AS1-1(config-if)# exit

# VLAN CONFIGURATION
# Create and name VLANs
AS1-1(config)# vlan 10
AS1-1(config-vlan)# name ORANGE
AS1-1(config-vlan)# exit

AS1-1(config)# vlan 11
AS1-1(config-vlan)# name GREEN
AS1-1(config-vlan)# exit

AS1-1(config)# vlan 12
AS1-1(config-vlan)# name BLUE
AS1-1(config-vlan)# exit

AS1-1(config)# vlan 99
AS1-1(config-vlan)# name MANAGEMENT
AS1-1(config-vlan)# exit

# TRUNK PORT CONFIGURATION
# Configure the trunk port and allowed VLANs
AS1-1(config)# interface g1/0/23
AS1-1(config-if)# switchport mode trunk
AS1-1(config-if)# switchport trunk allowed vlan 1,10,11,12,99
AS1-1(config-if)# exit

# ACCESS PORT CONFIGURATION
# Configure access ports for VLAN 10
AS1-1(config)# interface range g1/0/1 - 10
AS1-1(config-if)# switchport mode access
AS1-1(config-if)# switchport access vlan 10
AS1-1(config-if)# exit

# Configure access ports for VLAN 12
AS1-1(config)# interface range g1/0/11 - 20
AS1-1(config-if)# switchport mode access
AS1-1(config-if)# switchport access vlan 11
AS1-1(config-if)# exit

# SAVE CONFIGURATION
# Save the configuration to NVRAM to ensure it persists across reboots
AS1-1# write memory

