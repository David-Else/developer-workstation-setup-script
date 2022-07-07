The files in this directory were created using `rpmbuild`. As an example, here are the exact steps used to rebuild stow:

```bash
sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
sudo dnf install perl rpm-build perl-generators perl-IO-stringy perl-Test-Output

curl -O https://download-ib01.fedoraproject.org/pub/epel/8/Everything/SRPMS/Packages/s/stow-2.3.1-1.el8.src.rpm
rpmbuild --rebuild stow-2.3.1-1.el8.src.rpm
```
