# Queries for groups

## Sum of allocations for a group

SELECT groups.id, name, sum(allocations.amount) AS allocated
FROM groups
LEFT JOIN allocations ON allocations.group_id = groups.id
GROUP BY groups.id;

## Sum of contributions for a group 

SELECT groups.id, groups.name, contributed
FROM groups
LEFT JOIN (SELECT group_id, sum(contributions.amount) AS contributed
           FROM buckets, contributions
           WHERE contributions.bucket_id = buckets.id
           GROUP BY group_id) AS contrib ON contrib.group_id = groups.id;

## Group balance

SELECT groups.id, name, allocated, contributed, allocated - contributed as balance
FROM groups
LEFT JOIN (SELECT group_id, sum(allocations.amount) AS allocated
           FROM allocations
           GROUP BY group_id) AS alloc ON alloc.group_id = groups.id
LEFT JOIN (SELECT group_id, sum(contributions.amount) AS contributed
           FROM buckets, contributions
           WHERE contributions.bucket_id = buckets.id
           GROUP BY group_id) AS contrib ON contrib.group_id = groups.id;


## Groups with group balance < 0 (breaking invariant)

SELECT groups.id, name, allocated, contributed, allocated - contributed as balance
FROM groups
LEFT JOIN (SELECT group_id, sum(allocations.amount) AS allocated
           FROM allocations
           GROUP BY group_id) AS alloc ON alloc.group_id = groups.id
LEFT JOIN (SELECT group_id, sum(contributions.amount) AS contributed
           FROM buckets, contributions
           WHERE contributions.bucket_id = buckets.id
           GROUP BY group_id) AS contrib ON contrib.group_id = groups.id
WHERE balance < 0;

## Sum of allocations for a group, by summing for each user

SELECT groups.id, groups.name, sum(allocations.amount) AS userallocations
FROM memberships, users, groups, allocations
WHERE groups.id = memberships.group_id AND users.id = memberships.member_id AND
      allocations.group_id = groups.id AND allocations.user_id = users.id
GROUP BY groups.id;

## Difference between total allocations and allocations summed per user

SELECT groups.id, groups.name, sum(allocations.amount) AS userallocations, allocated, 
       sum(allocations.amount) - allocated AS diff
FROM memberships
INNER JOIN users ON users.id = memberships.member_id
INNER JOIN groups ON groups.id = memberships.group_id
LEFT JOIN allocations ON allocations.group_id = memberships.group_id AND allocations.user_id = memberships.member_id
LEFT JOIN (SELECT group_id, sum(allocations.amount) AS allocated
           FROM allocations
           GROUP BY group_id) AS alloc ON alloc.group_id = groups.id
GROUP BY groups.id, allocated;

## Groups where the difference between total allocations and allocations summed per user is non-zero (breaking invariant)

SELECT q.id, q.name, q.userallocations, q.allocated, q.diff 
FROM (SELECT groups.id, groups.name, sum(allocations.amount) AS userallocations, allocated, 
             sum(allocations.amount) - allocated AS diff
      FROM memberships
      INNER JOIN users ON users.id = memberships.member_id
      INNER JOIN groups ON groups.id = memberships.group_id
      LEFT JOIN allocations ON allocations.group_id = memberships.group_id AND allocations.user_id = memberships.member_id
      LEFT JOIN (SELECT group_id, sum(allocations.amount) AS allocated
                 FROM allocations
                 GROUP BY group_id) AS alloc ON alloc.group_id = groups.id
      GROUP BY groups.id, allocated) AS q
WHERE diff != 0;

# Queries for users

## Allocations for each user for each group

SELECT users.id, users.name, groups.name, sum(allocations.amount)
FROM memberships
INNER JOIN users ON users.id = memberships.member_id
INNER JOIN groups ON groups.id = memberships.group_id
LEFT JOIN allocations ON allocations.group_id = memberships.group_id AND allocations.user_id = memberships.member_id
GROUP BY users.id, groups.id
ORDER BY users.id;

## Contributions for each user for each group

SELECT b.userid, b.name, groups.name, sum(contributions)
FROM groups
INNER JOIN (SELECT buckets.id AS bucketid, buckets.group_id, users.id AS userid, users.name, 
                  sum(contributions.amount) AS contributions
           FROM contributions
           INNER JOIN users ON contributions.user_id = users.id
           INNER JOIN buckets ON contributions.bucket_id = buckets.id
           GROUP BY buckets.id, users.id) AS b ON b.group_id = groups.id
GROUP BY b.userid, b.name, groups.id
ORDER BY b.userid;

## Balance for each user for each group (disregarding if the user has contributed to a group without membership)



# Workspace

SELECT groups.id, groups.name, sum(allocations.amount) AS userallocations, allocated
FROM memberships
INNER JOIN users ON users.id = memberships.member_id
INNER JOIN groups ON groups.id = memberships.group_id
LEFT JOIN allocations ON allocations.group_id = memberships.group_id AND allocations.user_id = memberships.member_id
LEFT JOIN (SELECT group_id, sum(allocations.amount) AS allocated
           FROM allocations
           GROUP BY group_id) AS alloc ON alloc.group_id = groups.id
WHERE groups.id = 41
GROUP BY groups.id, allocated;

SELECT groups.name, sum(allocations.amount)
FROM memberships
INNER JOIN users ON users.id = memberships.member_id
INNER JOIN groups ON groups.id = memberships.group_id
LEFT JOIN allocations ON allocations.group_id = memberships.group_id AND allocations.user_id = memberships.member_id
WHERE groups.id = 41
GROUP BY groups.id;