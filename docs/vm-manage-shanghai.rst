to find vm's ip after the vm is installed by run.sh under ~/tools/libvirt


.. code-block:: bash

    $ virsh domiflist vmname
    $ arp -e

to combine them together

.. code-block:: bash

    $ for mac in `virsh domiflist qiwei-kolla |grep -o -E "([0-9a-f]{2}:){5}([0-9a-f]{2})"` ; do arp -e |grep $mac  |grep -o -P "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" ; done